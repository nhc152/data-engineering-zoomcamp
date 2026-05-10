# Phần 12: SQL Dialects

Mục tiêu của phần này: giúp bạn hiểu SQL không hoàn toàn giống nhau giữa các hệ quản trị. Senior Data Engineer cần đọc và chuyển đổi SQL giữa Oracle, PostgreSQL, SQL Server, MySQL, BigQuery, Snowflake, Spark SQL, Hive và Trino/Presto.

## 1. SQL dialect là gì?

SQL có chuẩn chung, nhưng mỗi database có cú pháp và hàm riêng.

Ví dụ lấy 10 dòng đầu:

Oracle 12c+:

```sql
SELECT *
FROM orders
FETCH FIRST 10 ROWS ONLY;
```

PostgreSQL/MySQL:

```sql
SELECT *
FROM orders
LIMIT 10;
```

SQL Server:

```sql
SELECT TOP 10 *
FROM orders;
```

Senior lesson: không copy SQL giữa platform mà không kiểm tra dialect.

## 2. Date/time functions

### Oracle

```sql
SELECT
  TRUNC(order_date) AS order_day,
  TRUNC(order_date, 'MM') AS order_month
FROM orders;
```

### PostgreSQL

```sql
SELECT
  DATE(order_date) AS order_day,
  DATE_TRUNC('month', order_date) AS order_month
FROM orders;
```

### BigQuery

```sql
SELECT
  DATE(order_timestamp) AS order_day,
  DATE_TRUNC(DATE(order_timestamp), MONTH) AS order_month
FROM orders;
```

### Snowflake

```sql
SELECT
  TO_DATE(order_timestamp) AS order_day,
  DATE_TRUNC('MONTH', order_timestamp) AS order_month
FROM orders;
```

## 3. String functions

Nối chuỗi:

Oracle/PostgreSQL:

```sql
SELECT first_name || ' ' || last_name AS full_name
FROM customers;
```

SQL Server:

```sql
SELECT first_name + ' ' + last_name AS full_name
FROM customers;
```

MySQL:

```sql
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM customers;
```

BigQuery/Snowflake cũng hỗ trợ `CONCAT`.

## 4. NULL handling

Chuẩn phổ biến:

```sql
COALESCE(value, 0)
```

Oracle cũ hay gặp:

```sql
NVL(value, 0)
```

SQL Server:

```sql
ISNULL(value, 0)
```

Nên ưu tiên `COALESCE` nếu muốn SQL dễ chuyển đổi hơn.

## 5. Type casting

Oracle:

```sql
CAST(order_date AS DATE)
```

PostgreSQL:

```sql
order_date::date
```

hoặc:

```sql
CAST(order_date AS DATE)
```

BigQuery:

```sql
CAST(order_timestamp AS DATE)
```

Snowflake:

```sql
order_timestamp::DATE
```

Tư duy senior: cast rõ ràng, tránh implicit conversion.

## 6. MERGE khác nhau

Oracle:

```sql
MERGE INTO dim_customer t
USING stg_customer s
ON (t.customer_id = s.customer_id)
WHEN MATCHED THEN
  UPDATE SET t.full_name = s.full_name
WHEN NOT MATCHED THEN
  INSERT (customer_id, full_name)
  VALUES (s.customer_id, s.full_name);
```

BigQuery:

```sql
MERGE dataset.dim_customer t
USING dataset.stg_customer s
ON t.customer_id = s.customer_id
WHEN MATCHED THEN
  UPDATE SET full_name = s.full_name
WHEN NOT MATCHED THEN
  INSERT (customer_id, full_name)
  VALUES (s.customer_id, s.full_name);
```

PostgreSQL thường dùng `INSERT ... ON CONFLICT`:

```sql
INSERT INTO dim_customer (customer_id, full_name)
VALUES (1, 'Nguyen An')
ON CONFLICT (customer_id)
DO UPDATE SET full_name = EXCLUDED.full_name;
```

## 7. QUALIFY

Snowflake và BigQuery hỗ trợ `QUALIFY`:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC
  ) AS rn
FROM orders
QUALIFY rn = 1;
```

Oracle/PostgreSQL không dùng phổ biến cú pháp này, viết bằng CTE:

```sql
WITH ranked AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date DESC
    ) AS rn
  FROM orders
)
SELECT *
FROM ranked
WHERE rn = 1;
```

## 8. Arrays và structs

BigQuery hỗ trợ nested data mạnh:

```sql
SELECT
  order_id,
  item.product_id,
  item.quantity
FROM orders,
UNNEST(items) AS item;
```

PostgreSQL có array/json riêng.

Snowflake có `VARIANT`, `LATERAL FLATTEN`.

Oracle có JSON functions và `JSON_TABLE`.

Spark SQL có `explode`.

Senior Data Engineer cần biết platform mình dùng xử lý nested data theo cách nào.

## 9. Temporary table

Oracle:

```sql
CREATE GLOBAL TEMPORARY TABLE tmp_orders (
  order_id NUMBER
) ON COMMIT PRESERVE ROWS;
```

PostgreSQL:

```sql
CREATE TEMP TABLE tmp_orders AS
SELECT *
FROM orders;
```

Snowflake:

```sql
CREATE TEMPORARY TABLE tmp_orders AS
SELECT *
FROM orders;
```

BigQuery thường dùng temporary table trong script:

```sql
CREATE TEMP TABLE tmp_orders AS
SELECT *
FROM orders;
```

## 10. Boolean khác nhau

PostgreSQL, BigQuery, Snowflake có boolean rõ:

```sql
WHERE is_active = TRUE
```

Oracle truyền thống thường dùng:

```sql
WHERE is_active = 'Y'
```

hoặc:

```sql
WHERE is_active = 1
```

Khi migrate, cần mapping boolean rõ.

## 11. Identifier case sensitivity

Một số database xử lý chữ hoa/thường khác nhau.

Oracle thường lưu unquoted identifier thành uppercase:

```sql
SELECT * FROM orders;
```

có thể thành `ORDERS`.

PostgreSQL lưu unquoted identifier thành lowercase.

Nếu dùng quoted identifier:

```sql
SELECT * FROM "Orders";
```

tên trở nên case-sensitive.

Senior lesson: tránh đặt tên bảng/cột phải quote nếu không có lý do mạnh.

## 12. Transaction support

Không phải warehouse nào xử lý transaction giống OLTP database.

Cần kiểm tra:

- DDL có auto commit không?
- `MERGE` có atomic không?
- Temporary table sống trong session hay transaction?
- Delete/insert lớn có rollback được không?
- Streaming insert có transaction không?

Đây là điểm quan trọng khi thiết kế pipeline retry-safe.

## 13. Performance model khác nhau

Row-store database như Oracle/PostgreSQL:

- Index rất quan trọng.
- Execution plan chi tiết.
- Join strategy và statistics quan trọng.

Columnar warehouse như BigQuery/Snowflake:

- Chỉ chọn cột cần dùng rất quan trọng.
- Partition/clustering quan trọng.
- Bytes scanned/cost quan trọng.
- Index truyền thống ít hoặc không phải trọng tâm.

Spark SQL:

- Shuffle là bottleneck lớn.
- File size, partition, skew rất quan trọng.
- Broadcast join có thể hữu ích.

## 14. Migrate SQL giữa dialects

Khi chuyển SQL, cần kiểm tra:

- Date/time functions.
- Timezone behavior.
- String concatenation.
- Null handling.
- Limit/top/fetch.
- Merge/upsert.
- JSON/array functions.
- Temporary table.
- Transaction behavior.
- Quoted identifiers.
- Data type mapping.

Không nên chỉ sửa cú pháp cho chạy. Phải kiểm tra kết quả số liệu.

## 15. Lỗi dialect phổ biến

- Dùng `LIMIT` trong Oracle.
- Dùng `NVL` trong PostgreSQL.
- Dùng `DATE_TRUNC` sai cú pháp giữa BigQuery và PostgreSQL.
- Migrate timestamp nhưng mất timezone.
- `MERGE` chạy khác behavior.
- Boolean mapping sai.
- String concat bằng `+` trong database không hỗ trợ.
- Dùng quoted identifier làm query khó bảo trì.

## 16. Checklist khi làm đa dialect

- SQL chạy trên engine nào?
- Hàm ngày/tháng đúng dialect chưa?
- Timestamp/timezone đúng chưa?
- Upsert/Merge đúng behavior chưa?
- NULL handling có giống không?
- Data type có mapping đúng không?
- Query performance model của engine là gì?
- Kết quả đã đối soát với bản cũ chưa?

## 17. Bài tập tự luyện

### Bài 1

Viết query lấy 10 order mới nhất trong Oracle, PostgreSQL và SQL Server.

### Bài 2

Chuyển `NVL(amount, 0)` sang dạng portable hơn.

### Bài 3

Viết logic lấy order mới nhất mỗi customer bằng `QUALIFY`, sau đó viết lại bằng CTE.

### Bài 4

Liệt kê các điểm cần kiểm tra khi migrate SQL từ Oracle sang BigQuery.

### Bài 5

Giải thích vì sao cùng một query có thể cần tối ưu khác nhau trên PostgreSQL và BigQuery.

## 18. Từ fresher lên senior ở SQL dialects

Fresher thường nghĩ: "SQL ở đâu cũng giống nhau."

Senior hiểu:

- Cú pháp khác.
- Function khác.
- Transaction khác.
- Optimizer khác.
- Performance model khác.
- Cùng kết quả nhưng chi phí có thể rất khác.

Biết dialect giúp bạn tránh lỗi khi làm nhiều hệ thống dữ liệu.

