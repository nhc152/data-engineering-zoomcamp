# Phần 3: Aggregation và phân tích dữ liệu

Mục tiêu của phần này: giúp bạn tính toán chỉ số đúng bằng SQL. Data Engineer thường phải tạo metric cho dashboard, đối soát số liệu và xây bảng tổng hợp. Sai aggregation là một trong những lỗi nghiêm trọng nhất.

## 1. Aggregation là gì?

Aggregation là gom nhiều dòng dữ liệu thành kết quả tổng hợp.

Ví dụ:

```sql
SELECT
  status,
  COUNT(*) AS order_count
FROM orders
GROUP BY status;
```

Kết quả có thể là:

| status    | order_count |
|-----------|-------------|
| PAID      | 2           |
| PENDING   | 1           |
| CANCELLED | 1           |

## 2. GROUP BY

`GROUP BY` gom dữ liệu theo một hoặc nhiều cột.

Doanh thu theo customer:

```sql
SELECT
  customer_id,
  SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'PAID'
GROUP BY customer_id;
```

Doanh thu theo ngày:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'PAID'
GROUP BY CAST(order_date AS DATE);
```

Lưu ý tùy database, cách lấy phần ngày từ timestamp khác nhau:

- Oracle: `TRUNC(order_date)`
- PostgreSQL: `DATE(order_date)` hoặc `DATE_TRUNC('day', order_date)`
- BigQuery: `DATE(order_date)`
- Snowflake: `TO_DATE(order_date)`

## 3. COUNT(*) vs COUNT(column)

`COUNT(*)` đếm số dòng.

```sql
SELECT COUNT(*) AS row_count
FROM orders;
```

`COUNT(column)` chỉ đếm dòng mà column không `NULL`.

```sql
SELECT COUNT(customer_id) AS customer_id_count
FROM orders;
```

Ví dụ:

| order_id | customer_id |
|----------|-------------|
| 1        | 10          |
| 2        | NULL        |
| 3        | 20          |

Kết quả:

- `COUNT(*) = 3`
- `COUNT(customer_id) = 2`

Lỗi thường gặp: dùng `COUNT(column)` khi muốn đếm tất cả dòng.

## 4. COUNT DISTINCT

Đếm số customer có order:

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;
```

Cẩn thận:

- `COUNT(DISTINCT ...)` có thể tốn tài nguyên trên dữ liệu lớn.
- Nếu cần tính thường xuyên, có thể cần bảng aggregate hoặc approximate count tùy hệ thống.

Ví dụ approximate trong BigQuery:

```sql
SELECT APPROX_COUNT_DISTINCT(customer_id) AS approx_unique_customers
FROM orders;
```

## 5. SUM, AVG, MIN, MAX

```sql
SELECT
  COUNT(*) AS order_count,
  SUM(total_amount) AS revenue,
  AVG(total_amount) AS avg_order_value,
  MIN(total_amount) AS min_order_value,
  MAX(total_amount) AS max_order_value
FROM orders
WHERE status = 'PAID';
```

Lưu ý với `AVG`:

```sql
AVG(total_amount)
```

bỏ qua `NULL`.

Nếu `NULL` nghĩa là 0 theo nghiệp vụ, phải xử lý:

```sql
AVG(COALESCE(total_amount, 0))
```

Nhưng không được tự ý thay `NULL` bằng 0 nếu nghiệp vụ không nói rõ.

## 6. HAVING

`WHERE` lọc trước khi group. `HAVING` lọc sau khi group.

Customer có doanh thu trên 1,000,000:

```sql
SELECT
  customer_id,
  SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'PAID'
GROUP BY customer_id
HAVING SUM(total_amount) > 1000000;
```

Không thể viết:

```sql
WHERE SUM(total_amount) > 1000000
```

vì `WHERE` chạy trước aggregation.

## 7. Conditional aggregation

Đây là kỹ thuật cực kỳ quan trọng.

Đếm số order theo trạng thái trong cùng một dòng:

```sql
SELECT
  customer_id,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN status = 'PAID' THEN 1 ELSE 0 END) AS paid_orders,
  SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_orders,
  SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_orders
FROM orders
GROUP BY customer_id;
```

Tính doanh thu paid và pending:

```sql
SELECT
  customer_id,
  SUM(CASE WHEN status = 'PAID' THEN total_amount ELSE 0 END) AS paid_revenue,
  SUM(CASE WHEN status = 'PENDING' THEN total_amount ELSE 0 END) AS pending_amount
FROM orders
GROUP BY customer_id;
```

Ứng dụng:

- Tính nhiều metric trong một query.
- Tạo bảng summary.
- Làm báo cáo theo nhiều trạng thái.

## 8. Tính tỷ lệ

Ví dụ tỷ lệ order cancelled:

```sql
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_orders,
  1.0 * SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) / COUNT(*) AS cancellation_rate
FROM orders;
```

Lưu ý:

- Nhân `1.0` để tránh chia nguyên ở một số database.
- Cần tránh chia cho 0.

An toàn hơn:

```sql
SELECT
  CASE
    WHEN COUNT(*) = 0 THEN 0
    ELSE 1.0 * SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) / COUNT(*)
  END AS cancellation_rate
FROM orders;
```

Một số database hỗ trợ `NULLIF`:

```sql
SELECT
  1.0 * SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*), 0) AS cancellation_rate
FROM orders;
```

## 9. Aggregation sau JOIN

Đây là phần rất dễ sai.

Sai:

```sql
SELECT
  c.city,
  SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN order_items i
  ON i.order_id = o.order_id
WHERE o.status = 'PAID'
GROUP BY c.city;
```

Nếu một order có nhiều item, `o.total_amount` bị cộng nhiều lần.

Đúng nếu revenue lấy từ order:

```sql
SELECT
  c.city,
  SUM(o.total_amount) AS revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
WHERE o.status = 'PAID'
GROUP BY c.city;
```

Đúng nếu revenue lấy từ item:

```sql
SELECT
  c.city,
  SUM(i.quantity * i.unit_price) AS revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN order_items i
  ON i.order_id = o.order_id
WHERE o.status = 'PAID'
GROUP BY c.city;
```

## 10. Aggregate trước rồi join

Kỹ thuật này giúp tránh nhân dòng.

Ví dụ cần lấy doanh thu từng customer và thông tin customer:

```sql
WITH order_revenue AS (
  SELECT
    customer_id,
    SUM(total_amount) AS revenue
  FROM orders
  WHERE status = 'PAID'
  GROUP BY customer_id
)
SELECT
  c.customer_id,
  c.full_name,
  COALESCE(r.revenue, 0) AS revenue
FROM customers c
LEFT JOIN order_revenue r
  ON r.customer_id = c.customer_id;
```

Lợi ích:

- Rõ grain của bảng trung gian.
- Giảm rủi ro duplicate.
- Dễ debug.

## 11. Date aggregation

Doanh thu theo ngày:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  SUM(total_amount) AS revenue
FROM orders
WHERE status = 'PAID'
GROUP BY CAST(order_date AS DATE)
ORDER BY order_day;
```

Doanh thu theo tháng:

PostgreSQL/Snowflake style:

```sql
SELECT
  DATE_TRUNC('month', order_date) AS order_month,
  SUM(total_amount) AS revenue
FROM orders
WHERE status = 'PAID'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;
```

Oracle style:

```sql
SELECT
  TRUNC(order_date, 'MM') AS order_month,
  SUM(total_amount) AS revenue
FROM orders
WHERE status = 'PAID'
GROUP BY TRUNC(order_date, 'MM')
ORDER BY order_month;
```

## 12. Rollup, Cube, Grouping Sets

Các tính năng này dùng cho báo cáo nhiều cấp tổng hợp.

Ví dụ doanh thu theo city và tổng toàn bộ:

```sql
SELECT
  city,
  SUM(total_amount) AS revenue
FROM customer_orders
GROUP BY ROLLUP(city);
```

Ví dụ grouping sets:

```sql
SELECT
  city,
  status,
  SUM(total_amount) AS revenue
FROM customer_orders
GROUP BY GROUPING SETS (
  (city, status),
  (city),
  (status),
  ()
);
```

Không phải fresher cần dùng ngay, nhưng senior nên biết để xử lý report tổng hợp phức tạp.

## 13. NULL trong aggregation

`SUM`, `AVG`, `MIN`, `MAX` bỏ qua `NULL`.

Ví dụ:

| amount |
|--------|
| 100    |
| NULL   |
| 300    |

Kết quả:

- `SUM(amount) = 400`
- `AVG(amount) = 200`
- `COUNT(amount) = 2`
- `COUNT(*) = 3`

Câu hỏi nghiệp vụ cần làm rõ:

- `NULL` nghĩa là chưa có dữ liệu?
- `NULL` nghĩa là 0?
- `NULL` nghĩa là lỗi?

Không tự ý xử lý `NULL` nếu chưa hiểu ý nghĩa.

## 14. Minh họa thực tế: đối soát doanh thu

Tình huống:

Dashboard báo doanh thu ngày 2026-05-08 là 100 triệu, nhưng source system báo 95 triệu.

Các bước debug bằng SQL:

### Bước 1: kiểm tra tổng source

```sql
SELECT
  SUM(total_amount) AS source_revenue
FROM orders
WHERE status = 'PAID'
  AND order_date >= TIMESTAMP '2026-05-08 00:00:00'
  AND order_date <  TIMESTAMP '2026-05-09 00:00:00';
```

### Bước 2: kiểm tra target

```sql
SELECT
  SUM(revenue) AS target_revenue
FROM fact_daily_revenue
WHERE revenue_date = DATE '2026-05-08';
```

### Bước 3: kiểm tra duplicate order trong target

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
WHERE order_date >= TIMESTAMP '2026-05-08 00:00:00'
  AND order_date <  TIMESTAMP '2026-05-09 00:00:00'
GROUP BY order_id
HAVING COUNT(*) > 1;
```

### Bước 4: kiểm tra order thiếu

```sql
SELECT o.order_id
FROM orders o
LEFT JOIN fact_orders f
  ON f.order_id = o.order_id
WHERE o.status = 'PAID'
  AND o.order_date >= TIMESTAMP '2026-05-08 00:00:00'
  AND o.order_date <  TIMESTAMP '2026-05-09 00:00:00'
  AND f.order_id IS NULL;
```

Senior lesson: debug metric bằng cách tách vấn đề thành row count, duplicate, missing, sum difference.

## 15. Lỗi aggregation phổ biến

- Aggregate sau join nhưng không kiểm soát grain.
- Dùng `COUNT(column)` khi cần `COUNT(*)`.
- Quên `WHERE status = 'PAID'` khi tính revenue.
- Dùng `DISTINCT` trong aggregate mà không hiểu tác động.
- Group theo timestamp thay vì date/month.
- Không xử lý timezone.
- Tính tỷ lệ nhưng không tránh chia cho 0.
- Tự ý thay `NULL` bằng 0.
- Không đối soát tổng sau khi transform.

## 16. Checklist aggregation

- Metric này định nghĩa là gì?
- Grain của kết quả là gì?
- Nguồn dữ liệu có duplicate không?
- Có join trước khi aggregate không?
- Nếu có join, grain có bị thay đổi không?
- Dùng `COUNT(*)` hay `COUNT(column)`?
- Có cần `COUNT(DISTINCT)` không?
- Có filter đúng trạng thái/ngày không?
- Có xử lý `NULL` đúng nghiệp vụ không?
- Có kiểm tra tổng với source không?

## 17. Bài tập tự luyện

### Bài 1

Tính số order theo từng `status`.

### Bài 2

Tính doanh thu `PAID` theo từng customer.

### Bài 3

Tính tỷ lệ order bị cancelled trên toàn bộ order.

### Bài 4

Tính doanh thu theo city, lưu ý không để order bị nhân dòng.

### Bài 5

Tìm customer có tổng doanh thu `PAID` lớn hơn 1,000,000.

## 18. Từ fresher lên senior ở phần aggregation

Fresher thường hỏi: "Em dùng `SUM` như vậy được không?"

Senior hỏi:

- Đang sum ở grain nào?
- Dữ liệu có bị nhân sau join không?
- Metric định nghĩa theo order, item, user hay ngày?
- Có duplicate không?
- Có cần đối soát với source không?
- `NULL` trong cột này có nghĩa gì?

Aggregation là nơi SQL tạo ra số liệu cho business. Nếu sai, dashboard sai và quyết định kinh doanh cũng sai.

