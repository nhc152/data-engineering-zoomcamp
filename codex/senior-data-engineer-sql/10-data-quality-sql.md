# Phần 10: Data Quality bằng SQL

Mục tiêu của phần này: giúp bạn dùng SQL để kiểm tra dữ liệu đúng, đủ, mới, không trùng và nhất quán. Senior Data Engineer phải biết biến nghi ngờ thành test cụ thể.

## 1. Data quality là gì?

Data quality là mức độ dữ liệu đáp ứng yêu cầu sử dụng.

Dữ liệu tốt thường:

- Đúng.
- Đủ.
- Không trùng ngoài ý muốn.
- Đúng kiểu dữ liệu.
- Đúng range.
- Đúng quan hệ.
- Cập nhật kịp thời.
- Nhất quán giữa các hệ thống.

Data Engineer không chỉ tạo bảng. Phải chứng minh bảng đó đáng tin.

## 2. Các nhóm kiểm tra phổ biến

- Null check.
- Duplicate check.
- Unique key check.
- Referential integrity check.
- Range check.
- Accepted values check.
- Freshness check.
- Row count check.
- Reconciliation.
- Anomaly detection.
- Schema drift check.

## 3. Null check

Kiểm tra cột bắt buộc không được null.

```sql
SELECT *
FROM fact_orders
WHERE order_id IS NULL;
```

Đếm số dòng null:

```sql
SELECT
  COUNT(*) AS null_order_id_count
FROM fact_orders
WHERE order_id IS NULL;
```

Kiểm tra nhiều cột:

```sql
SELECT
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date
FROM fact_orders;
```

## 4. Duplicate check

Kiểm tra duplicate primary key:

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Với key nhiều cột:

```sql
SELECT
  order_id,
  product_id,
  COUNT(*) AS cnt
FROM fact_order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
```

Lưu ý: key phải dựa trên grain của bảng.

## 5. Referential integrity check

Kiểm tra fact có customer không tồn tại trong dimension:

```sql
SELECT
  f.customer_id,
  COUNT(*) AS missing_count
FROM fact_orders f
LEFT JOIN dim_customer d
  ON d.customer_id = f.customer_id
WHERE d.customer_id IS NULL
GROUP BY f.customer_id;
```

Nếu dùng surrogate key:

```sql
SELECT
  f.customer_key,
  COUNT(*) AS missing_count
FROM fact_orders f
LEFT JOIN dim_customer d
  ON d.customer_key = f.customer_key
WHERE d.customer_key IS NULL
GROUP BY f.customer_key;
```

## 6. Range check

Kiểm tra amount âm:

```sql
SELECT *
FROM fact_orders
WHERE total_amount < 0;
```

Kiểm tra ngày tương lai:

```sql
SELECT *
FROM fact_orders
WHERE order_date > CURRENT_TIMESTAMP;
```

Kiểm tra quantity không hợp lệ:

```sql
SELECT *
FROM fact_order_items
WHERE quantity <= 0;
```

## 7. Accepted values check

Kiểm tra trạng thái chỉ nằm trong danh sách hợp lệ:

```sql
SELECT
  status,
  COUNT(*) AS cnt
FROM fact_orders
WHERE status NOT IN ('PAID', 'PENDING', 'CANCELLED', 'REFUNDED')
   OR status IS NULL
GROUP BY status;
```

Tốt hơn nếu có bảng reference:

```sql
SELECT
  f.status,
  COUNT(*) AS cnt
FROM fact_orders f
LEFT JOIN ref_order_status s
  ON s.status = f.status
WHERE s.status IS NULL
GROUP BY f.status;
```

## 8. Freshness check

Kiểm tra dữ liệu có mới không:

```sql
SELECT
  MAX(updated_at) AS max_updated_at
FROM fact_orders;
```

Nếu pipeline phải cập nhật mỗi giờ:

```sql
SELECT
  CASE
    WHEN MAX(updated_at) >= CURRENT_TIMESTAMP - INTERVAL '1' HOUR THEN 'PASS'
    ELSE 'FAIL'
  END AS freshness_status
FROM fact_orders;
```

Cú pháp interval tùy database.

## 9. Row count check

So sánh số dòng source và target:

```sql
SELECT COUNT(*) AS source_count
FROM stg_orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

```sql
SELECT COUNT(*) AS target_count
FROM fact_orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

Có thể cho phép sai lệch nhỏ nếu nghiệp vụ có filter:

- Target chỉ lấy `PAID`.
- Target dedup.
- Target loại bản ghi test.

Không so sánh máy móc nếu logic source-target khác nhau.

## 10. Sum reconciliation

Đối soát tổng tiền:

```sql
SELECT
  SUM(total_amount) AS source_amount
FROM stg_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

```sql
SELECT
  SUM(total_amount) AS target_amount
FROM fact_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

Đối soát nên gồm:

- Row count.
- Sum amount.
- Min/max date.
- Duplicate key.
- Missing key.

## 11. Anomaly detection đơn giản

Kiểm tra số order hôm nay lệch mạnh so với trung bình 7 ngày:

```sql
WITH daily AS (
  SELECT
    CAST(order_date AS DATE) AS order_day,
    COUNT(*) AS order_count
  FROM fact_orders
  GROUP BY CAST(order_date AS DATE)
),
baseline AS (
  SELECT
    AVG(order_count) AS avg_7d
  FROM daily
  WHERE order_day >= CURRENT_DATE - INTERVAL '7' DAY
    AND order_day <  CURRENT_DATE
),
today AS (
  SELECT
    order_count AS today_count
  FROM daily
  WHERE order_day = CURRENT_DATE
)
SELECT
  t.today_count,
  b.avg_7d,
  CASE
    WHEN t.today_count < b.avg_7d * 0.5 THEN 'LOW_ANOMALY'
    WHEN t.today_count > b.avg_7d * 1.5 THEN 'HIGH_ANOMALY'
    ELSE 'NORMAL'
  END AS status
FROM today t
CROSS JOIN baseline b;
```

Đây là check đơn giản, không thay thế monitoring chuyên sâu nhưng rất hữu ích.

## 12. Schema drift

Schema drift xảy ra khi source thay đổi schema:

- Thêm cột.
- Xóa cột.
- Đổi kiểu dữ liệu.
- Đổi ý nghĩa cột.

Kiểm tra metadata tùy database.

Ví dụ Oracle:

```sql
SELECT
  column_name,
  data_type,
  nullable
FROM user_tab_columns
WHERE table_name = 'STG_ORDERS'
ORDER BY column_id;
```

So sánh với target:

```sql
SELECT
  column_name,
  data_type,
  nullable
FROM user_tab_columns
WHERE table_name = 'FACT_ORDERS'
ORDER BY column_id;
```

Senior lesson: schema drift có thể làm pipeline fail hoặc tệ hơn là chạy thành công nhưng ghi sai dữ liệu.

## 13. SCD2 quality checks

Kiểm tra mỗi natural key chỉ có một current record:

```sql
SELECT
  customer_id,
  COUNT(*) AS current_count
FROM dim_customer
WHERE is_current = 'Y'
GROUP BY customer_id
HAVING COUNT(*) <> 1;
```

Kiểm tra interval overlap:

```sql
SELECT
  a.customer_id,
  a.customer_key AS key_a,
  b.customer_key AS key_b
FROM dim_customer a
JOIN dim_customer b
  ON a.customer_id = b.customer_id
 AND a.customer_key <> b.customer_key
 AND a.valid_from < b.valid_to
 AND b.valid_from < a.valid_to;
```

Kiểm tra `valid_from < valid_to`:

```sql
SELECT *
FROM dim_customer
WHERE valid_from >= valid_to;
```

## 14. Data quality result table

Nên lưu kết quả test vào bảng để theo dõi lịch sử.

Ví dụ:

```sql
CREATE TABLE data_quality_results (
  test_name     VARCHAR2(255),
  table_name    VARCHAR2(255),
  status        VARCHAR2(20),
  failed_count  NUMBER,
  checked_at    TIMESTAMP
);
```

Insert kết quả:

```sql
INSERT INTO data_quality_results (
  test_name,
  table_name,
  status,
  failed_count,
  checked_at
)
SELECT
  'fact_orders_duplicate_order_id' AS test_name,
  'fact_orders' AS table_name,
  CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status,
  COUNT(*) AS failed_count,
  CURRENT_TIMESTAMP AS checked_at
FROM (
  SELECT order_id
  FROM fact_orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) x;
```

## 15. Minh họa thực tế: dashboard revenue sai

Tình huống:

Dashboard revenue hôm nay giảm 40%.

Kiểm tra theo thứ tự:

### Freshness

```sql
SELECT MAX(updated_at)
FROM fact_orders;
```

### Row count hôm nay

```sql
SELECT COUNT(*)
FROM fact_orders
WHERE order_date >= CURRENT_DATE
  AND order_date <  CURRENT_DATE + INTERVAL '1' DAY;
```

### Status distribution

```sql
SELECT
  status,
  COUNT(*) AS cnt,
  SUM(total_amount) AS amount
FROM fact_orders
WHERE order_date >= CURRENT_DATE
  AND order_date <  CURRENT_DATE + INTERVAL '1' DAY
GROUP BY status;
```

### Duplicate

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
WHERE order_date >= CURRENT_DATE
  AND order_date <  CURRENT_DATE + INTERVAL '1' DAY
GROUP BY order_id
HAVING COUNT(*) > 1;
```

### Missing từ source

```sql
SELECT s.order_id
FROM stg_orders s
LEFT JOIN fact_orders f
  ON f.order_id = s.order_id
WHERE s.order_date >= CURRENT_DATE
  AND s.order_date <  CURRENT_DATE + INTERVAL '1' DAY
  AND f.order_id IS NULL;
```

Senior lesson: đừng đoán. Kiểm tra freshness, count, distribution, duplicate, missing.

## 16. Test severity

Không phải test fail nào cũng nghiêm trọng như nhau.

Ví dụ:

### Critical

- Primary key duplicate.
- Fact thiếu dữ liệu nguyên ngày.
- Amount âm trong giao dịch không cho phép.
- SCD2 overlap.

### Warning

- Row count lệch dưới ngưỡng nhỏ.
- Một số dimension missing nhưng có unknown member.
- Freshness trễ vài phút.

### Info

- Distribution thay đổi nhẹ.
- Cột optional có null tăng.

Senior cần phân loại severity để alert không bị nhiễu.

## 17. Unknown member

Trong data warehouse, đôi khi fact có dimension key chưa map được.

Có thể dùng unknown member:

```text
customer_key = -1
```

Trong `dim_customer`:

| customer_key | customer_id | full_name |
|--------------|-------------|-----------|
| -1           | UNKNOWN     | Unknown Customer |

Lợi ích:

- Fact không bị mất.
- Dashboard vẫn chạy.
- Có thể theo dõi tỷ lệ unknown.

Kiểm tra:

```sql
SELECT
  COUNT(*) AS unknown_customer_count
FROM fact_orders
WHERE customer_key = -1;
```

Nếu tỷ lệ unknown tăng cao, cần điều tra pipeline dimension.

## 18. Lỗi data quality phổ biến

- Chỉ kiểm tra row count, không kiểm tra sum.
- Không kiểm tra duplicate key.
- Không kiểm tra null ở cột bắt buộc.
- Không kiểm tra referential integrity.
- Không lưu lịch sử kết quả test.
- Alert quá nhiều khiến team bỏ qua.
- Không phân biệt critical/warning.
- Không test SCD2 overlap.
- Không kiểm tra freshness.
- Không kiểm tra distribution thay đổi bất thường.

## 19. Checklist data quality

- Primary key có unique không?
- Cột bắt buộc có null không?
- Foreign key có match dimension không?
- Giá trị có nằm trong range hợp lệ không?
- Status/category có nằm trong danh sách hợp lệ không?
- Dữ liệu có mới không?
- Row count source-target có hợp lý không?
- Sum amount source-target có khớp không?
- Distribution có bất thường không?
- Có schema drift không?
- Test fail có severity rõ không?
- Kết quả test có được lưu lại không?

## 20. Bài tập tự luyện

### Bài 1

Viết SQL kiểm tra duplicate `order_id` trong `fact_orders`.

### Bài 2

Viết SQL kiểm tra order có `customer_id` không tồn tại trong `dim_customer`.

### Bài 3

Viết SQL kiểm tra `total_amount` âm hoặc null.

### Bài 4

Viết SQL kiểm tra freshness của bảng `fact_events`, yêu cầu có dữ liệu trong 2 giờ gần nhất.

### Bài 5

Thiết kế bảng lưu kết quả data quality test.

## 21. Từ fresher lên senior ở phần data quality

Fresher thường nghĩ: "Pipeline chạy xanh là dữ liệu đúng."

Senior nghĩ:

- Dữ liệu có đủ không?
- Có duplicate không?
- Có missing dimension không?
- Có lệch so với source không?
- Có mới không?
- Có bất thường so với lịch sử không?
- Nếu sai thì alert ai và mức độ nào?

Data quality là lớp bảo hiểm của hệ thống dữ liệu. Không có nó, bạn chỉ biết dữ liệu sai sau khi business phàn nàn.

