# Phần 16: Những lỗi SQL senior phải tránh

Mục tiêu của phần này: tổng hợp các lỗi SQL nguy hiểm trong môi trường production. Đây là các lỗi có thể làm sai số liệu, làm chậm hệ thống, gây duplicate hoặc làm mất dữ liệu.

## 1. Dùng SELECT * trong pipeline production

Không nên:

```sql
INSERT INTO fact_orders
SELECT *
FROM stg_orders;
```

Rủi ro:

- Source thêm cột làm pipeline lỗi.
- Thứ tự cột khác nhau làm ghi sai dữ liệu.
- Lấy dư dữ liệu.
- Khó review.

Nên:

```sql
INSERT INTO fact_orders (
  order_id,
  customer_id,
  order_date,
  status,
  total_amount
)
SELECT
  order_id,
  customer_id,
  order_date,
  status,
  total_amount
FROM stg_orders;
```

## 2. Không xác định grain

Lỗi:

```text
Bảng này lưu order và product.
```

Không rõ mỗi dòng là order hay order item.

Đúng:

```text
fact_order_items: mỗi dòng là một product trong một order.
```

Nếu grain không rõ, aggregation và join rất dễ sai.

## 3. Join không kiểm tra cardinality

Sai:

```sql
SELECT
  SUM(o.total_amount) AS revenue
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id;
```

Nếu một order có nhiều item, `total_amount` bị nhân.

Trước khi join, kiểm tra:

```sql
SELECT
  order_id,
  COUNT(*) AS item_count
FROM order_items
GROUP BY order_id
HAVING COUNT(*) > 1;
```

## 4. Dùng DISTINCT để che lỗi duplicate

Không nên:

```sql
SELECT DISTINCT
  customer_id,
  full_name
FROM customer_orders;
```

nếu chưa hiểu vì sao duplicate.

Nên tìm nguyên nhân:

```sql
SELECT
  customer_id,
  COUNT(*) AS cnt
FROM customer_orders
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

`DISTINCT` không phải thuốc chữa mọi duplicate.

## 5. Dùng INNER JOIN làm mất fact

```sql
SELECT
  SUM(f.total_amount) AS revenue
FROM fact_orders f
JOIN dim_customer d
  ON d.customer_id = f.customer_id;
```

Nếu dimension thiếu customer, order bị loại.

Kiểm tra:

```sql
SELECT
  f.customer_id,
  COUNT(*) AS cnt
FROM fact_orders f
LEFT JOIN dim_customer d
  ON d.customer_id = f.customer_id
WHERE d.customer_id IS NULL
GROUP BY f.customer_id;
```

## 6. Filter bảng phải của LEFT JOIN trong WHERE

Sai:

```sql
SELECT
  c.customer_id,
  o.order_id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id
WHERE o.status = 'PAID';
```

Câu này loại customer không có order paid.

Đúng nếu muốn giữ toàn bộ customers:

```sql
SELECT
  c.customer_id,
  o.order_id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id
 AND o.status = 'PAID';
```

## 7. So sánh NULL sai

Sai:

```sql
WHERE email = NULL
```

Đúng:

```sql
WHERE email IS NULL
```

Cẩn thận:

```sql
WHERE status <> 'CANCELLED'
```

không lấy dòng `status IS NULL`.

## 8. Date/time sai timezone

Lỗi:

- Source timestamp UTC.
- Dashboard group theo local date.
- Pipeline không convert timezone.

Kết quả: số liệu theo ngày lệch.

Senior phải luôn hỏi:

- Timestamp lưu timezone nào?
- Metric báo cáo theo timezone nào?
- Partition date là UTC hay local?

## 9. Dùng function trên partition/index column

Không tốt:

```sql
WHERE TRUNC(order_date) = DATE '2026-05-08'
```

Tốt hơn:

```sql
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
```

## 10. Implicit type conversion

Không tốt:

```sql
WHERE customer_id = '1001'
```

nếu `customer_id` là number.

Không tốt:

```sql
WHERE order_date = '2026-05-08'
```

nếu `order_date` là date/timestamp.

Nên dùng đúng kiểu:

```sql
WHERE customer_id = 1001
```

```sql
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09'
```

## 11. Pipeline không idempotent

Không an toàn:

```sql
INSERT INTO fact_orders
SELECT *
FROM stg_orders
WHERE order_date = DATE '2026-05-08';
```

Retry sẽ duplicate.

Tốt hơn:

```sql
DELETE FROM fact_orders
WHERE order_date = DATE '2026-05-08';

INSERT INTO fact_orders (...)
SELECT ...
FROM stg_orders
WHERE order_date = DATE '2026-05-08';
```

Hoặc dùng `MERGE`.

## 12. MERGE source bị duplicate key

Trước `MERGE`, kiểm tra:

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Nếu source duplicate, merge có thể lỗi hoặc update không xác định.

Dedup trước:

```sql
WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY updated_at DESC, ingestion_id DESC
    ) AS rn
  FROM stg_orders
)
SELECT *
FROM ranked
WHERE rn = 1;
```

## 13. Commit từng dòng

Không tốt:

```text
For each row:
  insert
  commit
```

Rủi ro:

- Chậm.
- Khó rollback.
- Overhead log/redo lớn.
- Dữ liệu nửa vời nếu fail.

Nên xử lý theo batch hợp lý.

## 14. Update/delete thiếu WHERE

Nguy hiểm:

```sql
DELETE FROM fact_orders;
```

hoặc:

```sql
UPDATE dim_customer
SET is_current = 'N';
```

Trong production, trước khi delete/update lớn:

- Chạy `SELECT COUNT(*)` với cùng `WHERE`.
- Kiểm tra date range.
- Backup/snapshot nếu cần.
- Chạy trong transaction nếu database hỗ trợ.

## 15. Không kiểm tra data quality sau load

Pipeline chạy xanh không có nghĩa dữ liệu đúng.

Sau load cần kiểm tra:

- Row count.
- Duplicate key.
- Null critical columns.
- Sum reconciliation.
- Freshness.
- Referential integrity.

## 16. Không xử lý late arriving data

Sai:

```sql
WHERE order_date = CURRENT_DATE
```

nếu dữ liệu ngày cũ có thể đến muộn.

Cách tốt:

- Load theo `updated_at`.
- Reprocess N ngày gần nhất.
- Dùng overlap window.
- Dùng CDC.

## 17. Window function thiếu tie-breaker

Không ổn định:

```sql
ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY updated_at DESC
) AS rn
```

Nếu hai dòng cùng `updated_at`, kết quả có thể không ổn định.

Tốt hơn:

```sql
ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY updated_at DESC, ingestion_id DESC
) AS rn
```

## 18. LAST_VALUE sai frame

Không chắc đúng:

```sql
LAST_VALUE(order_date) OVER (
  PARTITION BY customer_id
  ORDER BY order_date
) AS last_order_date
```

Nên viết rõ:

```sql
LAST_VALUE(order_date) OVER (
  PARTITION BY customer_id
  ORDER BY order_date
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS last_order_date
```

## 19. Query dữ liệu lớn không filter partition

Không tốt:

```sql
SELECT COUNT(*)
FROM fact_events
WHERE event_name = 'purchase';
```

Tốt hơn:

```sql
SELECT COUNT(*)
FROM fact_events
WHERE event_date >= DATE '2026-05-01'
  AND event_date <  DATE '2026-06-01'
  AND event_name = 'purchase';
```

## 20. Không document metric definition

Metric "revenue" có thể có nhiều nghĩa:

- Gross revenue.
- Net revenue.
- Paid only.
- Excluding refunded.
- Including tax.
- Excluding shipping fee.

Nếu không document, mỗi team sẽ tính một kiểu.

## 21. Checklist tránh lỗi production

- Có dùng `SELECT *` không?
- Grain có rõ không?
- Join có làm nhân/mất dòng không?
- `NULL` đã xử lý đúng chưa?
- Date/timezone đúng chưa?
- Query có filter partition không?
- Pipeline có idempotent không?
- Merge source có duplicate không?
- Có data quality checks không?
- Metric definition có rõ không?
- Có kiểm tra row count/sum trước sau không?

## 22. Bài tập tự luyện

### Bài 1

Chỉ ra lỗi trong query `SUM(o.total_amount)` sau khi join `order_items`.

### Bài 2

Viết lại query dùng `SELECT *` trong insert production thành dạng an toàn.

### Bài 3

Giải thích vì sao filter bảng phải trong `WHERE` làm `LEFT JOIN` sai.

### Bài 4

Thiết kế checklist trước khi chạy `DELETE` trên bảng production.

### Bài 5

Giải thích vì sao `ROW_NUMBER` cần tie-breaker.

## 23. Từ fresher lên senior ở phần lỗi cần tránh

Fresher thường sửa lỗi khi nó xảy ra.

Senior thiết kế để lỗi khó xảy ra:

- Viết SQL rõ.
- Kiểm tra grain.
- Làm pipeline idempotent.
- Thêm data quality tests.
- Review impact trước khi chạy production.

Senior không phải người không bao giờ mắc lỗi, mà là người xây hệ thống để lỗi bị phát hiện sớm và ít gây hại.

