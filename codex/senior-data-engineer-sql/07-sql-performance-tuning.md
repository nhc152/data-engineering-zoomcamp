# Phần 7: SQL Performance Tuning

Mục tiêu của phần này: giúp bạn hiểu vì sao SQL chậm và biết cách tối ưu có phương pháp. Senior Data Engineer không tuning theo cảm tính, mà đo, đọc execution plan, xác định bottleneck rồi sửa đúng chỗ.

## 1. SQL chậm vì những lý do nào?

Một query có thể chậm vì:

- Đọc quá nhiều dữ liệu.
- Không dùng index/partition hiệu quả.
- Join sai thứ tự hoặc sai chiến lược.
- Sort/hash quá lớn.
- Statistics sai.
- Data skew.
- Dùng function trên cột filter.
- Implicit type conversion.
- Trả quá nhiều dòng qua network.
- Bị lock/blocking.
- Thiếu tài nguyên CPU, memory, I/O.

Tư duy senior: không hỏi "thêm index được không?" đầu tiên. Hỏi "query đang tốn ở đâu?".

## 2. Quy trình tuning cơ bản

1. Xác định SQL chậm cụ thể.
2. Lấy thời gian chạy, số dòng trả về, tần suất chạy.
3. Xem execution plan.
4. Xem số dòng estimated vs actual nếu có.
5. Tìm bước tốn tài nguyên nhất.
6. Kiểm tra filter, join, sort, scan.
7. Đề xuất thay đổi nhỏ nhất có ý nghĩa.
8. Chạy lại và so sánh trước/sau.

Không nên sửa nhiều thứ cùng lúc vì sẽ không biết thay đổi nào tạo ra hiệu quả.

## 3. Execution plan

Execution plan cho biết database chạy SQL như thế nào.

Các thông tin cần xem:

- Bảng nào được đọc.
- Dùng full table scan hay index scan.
- Join bằng nested loop, hash join hay merge join.
- Có sort/hash/group lớn không.
- Predicate được dùng để access hay chỉ filter.
- Số dòng estimated và actual.
- Số block/buffer đọc.

Oracle:

```sql
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(
  NULL,
  NULL,
  'ALLSTATS LAST +PREDICATE +ALIAS +PEEKED_BINDS'
));
```

PostgreSQL:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT ...
```

BigQuery:

Xem execution details trong UI, đặc biệt bytes processed, shuffle, slot time.

## 4. Estimated rows vs Actual rows

Nếu database ước lượng sai số dòng, plan có thể sai.

Ví dụ:

```text
Estimated rows: 100
Actual rows:    10,000,000
```

Rủi ro:

- Chọn nested loop khi đáng ra nên hash join.
- Dùng index lookup quá nhiều lần.
- Cấp memory sai cho sort/hash.

Nguyên nhân thường gặp:

- Statistics cũ.
- Data skew.
- Histogram thiếu.
- Predicate phức tạp.
- Bind variable.
- Correlation giữa các cột.

## 5. Index scan vs full table scan

Full table scan không luôn xấu.

Full scan có thể tốt khi:

- Bảng nhỏ.
- Query cần đọc phần lớn bảng.
- Index không chọn lọc.
- Warehouse đọc columnar scan nhanh hơn index.

Index scan tốt khi:

- Query lấy ít dòng.
- Filter có tính chọn lọc cao.
- Index phù hợp với `WHERE`, `JOIN`, `ORDER BY`.

Ví dụ:

```sql
SELECT *
FROM orders
WHERE order_id = 1001;
```

Nên có index/primary key trên `order_id`.

Nhưng:

```sql
SELECT *
FROM orders
WHERE status = 'PAID';
```

Nếu 90% orders là `PAID`, index trên `status` có thể không hữu ích.

## 6. Predicate pushdown

Predicate pushdown nghĩa là filter được đẩy xuống càng sớm càng tốt để giảm dữ liệu phải xử lý.

Tốt:

```sql
SELECT
  customer_id,
  SUM(total_amount) AS revenue
FROM orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-06-01'
  AND status = 'PAID'
GROUP BY customer_id;
```

Không tốt nếu filter bị áp dụng muộn do viết query phức tạp hoặc function không tối ưu.

Senior lesson: giảm dữ liệu càng sớm càng tốt, nhưng vẫn phải đúng logic.

## 7. Tránh function trên cột filter

Không tốt:

```sql
SELECT *
FROM orders
WHERE TRUNC(order_date) = DATE '2026-05-08';
```

Tốt hơn:

```sql
SELECT *
FROM orders
WHERE order_date >= DATE '2026-05-08'
  AND order_date <  DATE '2026-05-09';
```

Lợi ích:

- Dễ dùng index trên `order_date`.
- Dễ partition pruning.
- Ít xử lý hơn.

Nếu bắt buộc dùng function, cân nhắc function-based index tùy database.

## 8. Chỉ chọn cột cần dùng

Không tốt:

```sql
SELECT *
FROM fact_orders
WHERE order_date >= DATE '2026-05-01';
```

Tốt hơn:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM fact_orders
WHERE order_date >= DATE '2026-05-01';
```

Lợi ích:

- Giảm I/O.
- Giảm network.
- Tốt hơn cho columnar warehouse.
- Có thể dùng covering index trong row-store database.

## 9. Join tuning

Các vấn đề join thường làm query chậm:

- Join key không có index.
- Join sai kiểu dữ liệu.
- Join làm nhân dòng quá lớn.
- Filter đặt sau join thay vì trước join.
- Join bảng rất lớn với bảng rất lớn mà không partition/filter.

Tốt hơn khi aggregate trước:

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
  r.revenue
FROM order_revenue r
JOIN customers c
  ON c.customer_id = r.customer_id;
```

Thay vì join chi tiết rồi mới aggregate nếu không cần.

## 10. Sort tuning

`ORDER BY`, `GROUP BY`, `DISTINCT`, window functions đều có thể gây sort.

Ví dụ:

```sql
SELECT DISTINCT customer_id
FROM fact_orders;
```

Trên bảng lớn, `DISTINCT` có thể rất tốn.

Hỏi lại:

- Có thật sự cần distinct không?
- Dữ liệu có duplicate do lỗi upstream không?
- Có thể dùng bảng dimension/customer riêng không?
- Có index/sort key hỗ trợ không?

## 11. Pagination

Offset lớn thường chậm:

```sql
SELECT *
FROM orders
ORDER BY order_id
OFFSET 100000 ROWS FETCH NEXT 20 ROWS ONLY;
```

Database phải bỏ qua rất nhiều dòng.

Tốt hơn: keyset pagination.

```sql
SELECT *
FROM orders
WHERE order_id > :last_order_id
ORDER BY order_id
FETCH NEXT 20 ROWS ONLY;
```

Phù hợp cho API, export incremental, job quét dữ liệu.

## 12. CTE có luôn tốt không?

CTE giúp query dễ đọc:

```sql
WITH paid_orders AS (
  SELECT *
  FROM orders
  WHERE status = 'PAID'
)
SELECT *
FROM paid_orders;
```

Nhưng tùy database, CTE có thể:

- Được inline vào query chính.
- Bị materialize thành bảng tạm.

Nếu CTE bị materialize không cần thiết, query có thể chậm.

Senior lesson: dùng CTE để rõ logic, nhưng khi query chậm cần xem optimizer xử lý CTE thế nào.

## 13. UNION vs UNION ALL

`UNION` loại duplicate, cần sort/hash.

```sql
SELECT customer_id FROM online_orders
UNION
SELECT customer_id FROM offline_orders;
```

`UNION ALL` giữ toàn bộ dòng, thường nhanh hơn.

```sql
SELECT customer_id FROM online_orders
UNION ALL
SELECT customer_id FROM offline_orders;
```

Dùng `UNION ALL` nếu chắc chắn không cần loại trùng hoặc sẽ xử lý duplicate ở bước khác.

## 14. Statistics

Optimizer cần statistics để chọn plan.

Nếu stats cũ, query có thể chậm.

Oracle:

```sql
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'DW',
    tabname => 'FACT_ORDERS',
    cascade => TRUE
  );
END;
/
```

Kiểm tra:

```sql
SELECT
  table_name,
  num_rows,
  blocks,
  last_analyzed
FROM user_tables
WHERE table_name = 'FACT_ORDERS';
```

## 15. Data skew

Data skew là dữ liệu phân bố lệch.

Ví dụ `status`:

- `PAID`: 95%
- `CANCELLED`: 4%
- `FRAUD`: 1%

Query:

```sql
WHERE status = 'FRAUD'
```

rất khác:

```sql
WHERE status = 'PAID'
```

Nếu optimizer không biết skew, có thể chọn plan sai.

Cách xử lý:

- Histogram.
- Partition/filter tốt hơn.
- Rewrite query.
- Tách workload đặc biệt.

## 16. Materialized view và aggregate table

Nếu metric được query liên tục, đừng tính lại từ raw mỗi lần.

Ví dụ:

```sql
CREATE TABLE agg_daily_revenue AS
SELECT
  CAST(order_date AS DATE) AS revenue_date,
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE status = 'PAID'
GROUP BY CAST(order_date AS DATE);
```

Phù hợp cho:

- Dashboard.
- Báo cáo hàng ngày.
- Query tổng hợp lớn.

Đổi lại:

- Cần refresh strategy.
- Cần kiểm tra consistency.

## 17. Minh họa thực tế: query dashboard chậm

Query hiện tại:

```sql
SELECT
  c.city,
  SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c
  ON c.customer_id = o.customer_id
WHERE TO_CHAR(o.order_date, 'YYYY-MM') = '2026-05'
  AND o.status = 'PAID'
GROUP BY c.city
ORDER BY revenue DESC;
```

Vấn đề:

- Function `TO_CHAR` trên `order_date`.
- Có thể không dùng partition/index theo `order_date`.
- Dashboard tính lại từ chi tiết mỗi lần.

Viết tốt hơn:

```sql
SELECT
  c.city,
  SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c
  ON c.customer_id = o.customer_id
WHERE o.order_date >= DATE '2026-05-01'
  AND o.order_date <  DATE '2026-06-01'
  AND o.status = 'PAID'
GROUP BY c.city
ORDER BY revenue DESC;
```

Nếu vẫn chậm và dashboard chạy thường xuyên, tạo aggregate:

```sql
CREATE TABLE agg_monthly_city_revenue AS
SELECT
  TRUNC(o.order_date, 'MM') AS revenue_month,
  c.city,
  SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c
  ON c.customer_id = o.customer_id
WHERE o.status = 'PAID'
GROUP BY TRUNC(o.order_date, 'MM'), c.city;
```

## 18. Lỗi tuning phổ biến

- Tạo index trước khi xem plan.
- Chỉ nhìn cost, không nhìn actual rows/buffers.
- Tối ưu query nhưng không đo trước/sau.
- Dùng hint để ép plan mà không hiểu nguyên nhân.
- Thêm `DISTINCT` để giảm dòng nhưng che lỗi join.
- Không filter theo partition.
- Dùng function trên cột ngày.
- Dùng `SELECT *`.
- Không kiểm tra statistics.

## 19. Checklist performance tuning

- Query trả bao nhiêu dòng?
- Đọc bao nhiêu dữ liệu?
- Có filter sớm không?
- Có `SELECT *` không?
- Có function trên cột filter không?
- Có implicit conversion không?
- Join có đúng key và đúng grain không?
- Có sort/hash lớn không?
- Có dùng partition pruning không?
- Stats có mới không?
- Có data skew không?
- Có thể aggregate trước không?
- Có thể tạo aggregate table/materialized view không?

## 20. Bài tập tự luyện

### Bài 1

Viết lại query dùng `TRUNC(order_date)` trong `WHERE` sang dạng range.

### Bài 2

Giải thích khi nào full table scan là chấp nhận được.

### Bài 3

Một query có `E-Rows = 100`, `A-Rows = 5,000,000`. Liệt kê nguyên nhân có thể.

### Bài 4

So sánh `UNION` và `UNION ALL` về performance.

### Bài 5

Đề xuất cách tối ưu dashboard doanh thu theo ngày chạy trên bảng 1 tỷ dòng.

## 21. Từ fresher lên senior ở phần performance

Fresher thường hỏi: "Có cần thêm index không?"

Senior hỏi:

- Plan hiện tại là gì?
- Bottleneck là scan, join, sort, temp, I/O hay lock?
- Query có đọc quá nhiều dữ liệu không?
- Có thể giảm dữ liệu sớm hơn không?
- Tối ưu này có làm query khác hoặc DML chậm đi không?

Performance tuning là công việc dựa trên bằng chứng, không phải đoán.

