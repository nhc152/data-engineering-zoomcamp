# Phần 15: Debug dữ liệu bằng SQL

Mục tiêu của phần này: giúp bạn dùng SQL để điều tra khi số liệu sai, pipeline chậm, dữ liệu thiếu, duplicate tăng, hoặc dashboard lệch với source. Đây là kỹ năng phân biệt rõ junior và senior.

## 1. Debug dữ liệu là gì?

Debug dữ liệu là quá trình tìm nguyên nhân gốc khi dữ liệu không như kỳ vọng.

Ví dụ câu hỏi:

- Vì sao revenue hôm nay giảm 30%?
- Vì sao số user tăng gấp đôi?
- Vì sao dashboard lệch source?
- Vì sao pipeline chạy lâu hơn bình thường?
- Vì sao có nhiều `UNKNOWN` customer?
- Vì sao báo cáo mất dữ liệu một ngày?

Senior không đoán. Senior chia nhỏ vấn đề và kiểm tra bằng SQL.

## 2. Quy trình debug tổng quát

1. Xác định triệu chứng.
2. Xác định phạm vi: bảng nào, ngày nào, metric nào.
3. So sánh source và target.
4. Kiểm tra freshness.
5. Kiểm tra row count.
6. Kiểm tra duplicate.
7. Kiểm tra missing records.
8. Kiểm tra distribution.
9. Kiểm tra logic join/aggregation.
10. Xác định bước pipeline gây sai.

## 3. Bắt đầu bằng câu hỏi đúng

Không nên hỏi chung chung:

```text
Vì sao dữ liệu sai?
```

Nên cụ thể:

```text
Revenue ngày 2026-05-08 trên dashboard là 90 triệu, source là 120 triệu.
Metric revenue lấy đơn PAID, tính theo order_date timezone Asia/Ho_Chi_Minh.
```

Càng rõ definition, debug càng nhanh.

## 4. Kiểm tra freshness

```sql
SELECT
  MAX(updated_at) AS max_updated_at,
  MAX(inserted_at) AS max_inserted_at
FROM fact_orders;
```

Nếu max timestamp cũ, có thể pipeline chưa chạy hoặc fail.

Kiểm tra theo partition:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  COUNT(*) AS row_count,
  MAX(updated_at) AS max_updated_at
FROM fact_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE)
ORDER BY order_day;
```

## 5. Kiểm tra row count theo ngày

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  COUNT(*) AS cnt
FROM fact_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE)
ORDER BY order_day;
```

Nếu một ngày có count bằng 0 hoặc giảm mạnh, kiểm tra source cùng ngày.

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  COUNT(*) AS cnt
FROM stg_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE)
ORDER BY order_day;
```

## 6. So sánh source vs target

Row count:

```sql
SELECT 'source' AS src, COUNT(*) AS cnt
FROM stg_orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'

UNION ALL

SELECT 'target' AS src, COUNT(*) AS cnt
FROM fact_orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

Amount:

```sql
SELECT 'source' AS src, SUM(total_amount) AS amount
FROM stg_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'

UNION ALL

SELECT 'target' AS src, SUM(total_amount) AS amount
FROM fact_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

## 7. Tìm missing records

Record có ở source nhưng không có ở target:

```sql
SELECT
  s.order_id
FROM stg_orders s
LEFT JOIN fact_orders f
  ON f.order_id = s.order_id
WHERE s.order_date >= DATE '2026-05-08'
  AND s.order_date <  DATE '2026-05-09'
  AND f.order_id IS NULL;
```

Record có ở target nhưng không có ở source:

```sql
SELECT
  f.order_id
FROM fact_orders f
LEFT JOIN stg_orders s
  ON s.order_id = f.order_id
WHERE f.order_date >= DATE '2026-05-08'
  AND f.order_date <  DATE '2026-05-09'
  AND s.order_id IS NULL;
```

## 8. Tìm duplicate

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;
```

Duplicate theo partition:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_id) AS distinct_orders,
  COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_extra_rows
FROM fact_orders
GROUP BY CAST(order_date AS DATE)
ORDER BY order_day;
```

## 9. Kiểm tra distribution

Status distribution:

```sql
SELECT
  status,
  COUNT(*) AS cnt,
  SUM(total_amount) AS amount
FROM fact_orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
GROUP BY status
ORDER BY cnt DESC;
```

So với ngày trước:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  status,
  COUNT(*) AS cnt
FROM fact_orders
WHERE order_date >= DATE '2026-05-07'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE), status
ORDER BY order_day, status;
```

Nếu `PAID` giảm mạnh nhưng `PENDING` tăng, có thể source payment chưa cập nhật.

## 10. Kiểm tra join làm mất dữ liệu

Query dashboard:

```sql
SELECT
  c.city,
  SUM(f.total_amount) AS revenue
FROM fact_orders f
JOIN dim_customer c
  ON c.customer_id = f.customer_id
WHERE f.status = 'PAID'
GROUP BY c.city;
```

Nếu `dim_customer` thiếu customer, `INNER JOIN` làm mất orders.

Kiểm tra:

```sql
SELECT
  f.customer_id,
  COUNT(*) AS order_count,
  SUM(f.total_amount) AS amount
FROM fact_orders f
LEFT JOIN dim_customer c
  ON c.customer_id = f.customer_id
WHERE f.status = 'PAID'
  AND c.customer_id IS NULL
GROUP BY f.customer_id;
```

## 11. Kiểm tra join làm nhân dữ liệu

```sql
SELECT
  f.order_id,
  COUNT(*) AS joined_rows
FROM fact_orders f
JOIN dim_customer c
  ON c.customer_id = f.customer_id
GROUP BY f.order_id
HAVING COUNT(*) > 1;
```

Nếu `dim_customer` có duplicate `customer_id`, revenue có thể bị nhân.

Kiểm tra dimension duplicate:

```sql
SELECT
  customer_id,
  COUNT(*) AS cnt
FROM dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Với SCD2, phải join theo thời gian hoặc dùng `is_current` đúng mục tiêu.

## 12. Kiểm tra timezone

Lỗi timezone rất phổ biến.

Ví dụ source dùng UTC, dashboard dùng Asia/Ho_Chi_Minh.

Một order lúc:

```text
2026-05-07 18:00:00 UTC
```

tương đương:

```text
2026-05-08 01:00:00 Asia/Ho_Chi_Minh
```

Nếu group theo ngày UTC, order thuộc 2026-05-07. Nếu group theo giờ Việt Nam, thuộc 2026-05-08.

Checklist:

- Timestamp lưu timezone nào?
- Dashboard group theo timezone nào?
- ETL có convert timezone không?
- Date partition là UTC date hay local date?

## 13. Kiểm tra late arriving data

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  CAST(ingested_at AS DATE) AS ingestion_day,
  COUNT(*) AS cnt
FROM stg_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-05-09'
GROUP BY CAST(order_date AS DATE), CAST(ingested_at AS DATE)
ORDER BY order_day, ingestion_day;
```

Nếu nhiều order của ngày cũ được ingested hôm nay, pipeline chỉ xử lý current date sẽ bỏ sót.

## 14. Debug pipeline chậm

Kiểm tra:

- Input row count có tăng không?
- Partition có bị mất pruning không?
- Query plan có đổi không?
- Stats có cũ không?
- Có data skew không?
- Có lock/blocking không?
- Có small files problem không?

Ví dụ row count theo batch:

```sql
SELECT
  batch_id,
  COUNT(*) AS cnt,
  MIN(ingested_at) AS min_ingested_at,
  MAX(ingested_at) AS max_ingested_at
FROM stg_orders
GROUP BY batch_id
ORDER BY max_ingested_at DESC;
```

## 15. Debug bằng binary search layer

Nếu pipeline có các layer:

```text
stg_orders -> int_orders_deduped -> fact_orders -> agg_daily_revenue
```

Kiểm tra metric ở từng layer:

```sql
SELECT 'stg' AS layer, COUNT(*) AS cnt FROM stg_orders WHERE ...
UNION ALL
SELECT 'int' AS layer, COUNT(*) AS cnt FROM int_orders_deduped WHERE ...
UNION ALL
SELECT 'fact' AS layer, COUNT(*) AS cnt FROM fact_orders WHERE ...
UNION ALL
SELECT 'agg' AS layer, SUM(order_count) AS cnt FROM agg_daily_revenue WHERE ...;
```

Layer nào bắt đầu lệch là nơi cần điều tra sâu.

## 16. Viết query debug dễ đọc

Query debug nên:

- Giới hạn date range.
- Chọn cột cần thiết.
- Có alias rõ.
- Tách CTE theo bước.
- Ghi comment ngắn nếu logic phức tạp.

Không nên chạy query full table lớn khi chưa filter.

## 17. Mẫu debug incident revenue

1. Xác nhận metric definition.
2. Xác nhận timezone.
3. Kiểm tra freshness target.
4. So sánh row count source-target.
5. So sánh sum source-target.
6. Kiểm tra status distribution.
7. Kiểm tra duplicate order.
8. Kiểm tra missing order.
9. Kiểm tra dimension join.
10. Kiểm tra late arriving data.
11. Xác định layer bắt đầu lệch.
12. Ghi lại root cause và fix.

## 18. Lỗi debug phổ biến

- Đoán nguyên nhân trước khi kiểm tra.
- Không xác định metric definition.
- Debug trên toàn bộ dữ liệu thay vì date range nhỏ.
- Không so sánh source-target.
- Chỉ kiểm tra count, không kiểm tra sum.
- Quên timezone.
- Dùng `DISTINCT` để làm số liệu "đúng" mà không hiểu duplicate.
- Không lưu lại root cause.

## 19. Checklist debug dữ liệu

- Triệu chứng cụ thể là gì?
- Metric definition là gì?
- Date range và timezone là gì?
- Source đúng là bảng nào?
- Target đúng là bảng nào?
- Freshness có ổn không?
- Row count có lệch không?
- Sum có lệch không?
- Duplicate có tăng không?
- Missing records ở đâu?
- Join có mất/nhân dữ liệu không?
- Layer nào bắt đầu sai?

## 20. Bài tập tự luyện

### Bài 1

Dashboard revenue ngày 2026-05-08 thấp hơn source 20%. Viết checklist SQL debug.

### Bài 2

Viết query tìm order có trong source nhưng thiếu ở target.

### Bài 3

Viết query kiểm tra duplicate theo `order_id`.

### Bài 4

Giải thích lỗi timezone có thể làm số theo ngày lệch thế nào.

### Bài 5

Một join với `dim_customer` làm revenue giảm. Bạn kiểm tra gì?

## 21. Từ fresher lên senior ở debug dữ liệu

Fresher thường hỏi: "Em sửa query này được không?"

Senior hỏi:

- Sai bắt đầu từ layer nào?
- Có bằng chứng source-target không?
- Root cause là gì?
- Fix có ngăn lỗi lặp lại không?
- Có thêm data quality test sau incident không?

Debug tốt không chỉ sửa số liệu hôm nay, mà còn làm hệ thống khó sai lại.

