# Phần 1: Nền tảng SQL bắt buộc

Mục tiêu của phần này: giúp fresher nắm chắc SQL cơ bản theo cách đủ dùng trong công việc Data Engineer, không chỉ biết cú pháp mà còn hiểu khi nào dùng, dùng sai thì dữ liệu sai ở đâu.

## 1. SQL dùng để làm gì?

SQL là ngôn ngữ để làm việc với dữ liệu dạng bảng. Trong công việc Data Engineer, SQL thường dùng để:

- Lấy dữ liệu từ source system.
- Kiểm tra chất lượng dữ liệu.
- Biến đổi dữ liệu trong ETL/ELT.
- Tạo bảng trung gian, bảng fact, bảng dimension.
- Tính toán chỉ số cho báo cáo.
- Debug lỗi pipeline.
- So sánh dữ liệu giữa source và target.

Một Senior Data Engineer không chỉ viết SQL để "ra kết quả", mà phải viết SQL:

- Đúng logic nghiệp vụ.
- Không làm sai số liệu.
- Chạy hiệu quả trên dữ liệu lớn.
- Dễ đọc và dễ bảo trì.
- Có thể kiểm tra lại được.

## 2. Bộ bảng ví dụ

Các ví dụ trong tài liệu dùng mô hình bán hàng đơn giản.

### customers

| customer_id | full_name     | email              | city      | created_at          |
|-------------|---------------|--------------------|-----------|---------------------|
| 1           | Nguyen An     | an@example.com     | Ha Noi    | 2026-01-10 08:00:00 |
| 2           | Tran Binh     | binh@example.com   | Da Nang   | 2026-01-15 09:30:00 |
| 3           | Le Chi        | chi@example.com    | Ho Chi Minh | 2026-02-01 10:00:00 |

### orders

| order_id | customer_id | order_date          | status    | total_amount |
|----------|-------------|---------------------|-----------|--------------|
| 1001     | 1           | 2026-05-01 10:00:00 | PAID      | 500000       |
| 1002     | 1           | 2026-05-03 11:00:00 | CANCELLED | 200000       |
| 1003     | 2           | 2026-05-04 15:00:00 | PAID      | 800000       |
| 1004     | 3           | 2026-05-05 16:30:00 | PENDING   | 300000       |

### order_items

| order_id | product_id | quantity | unit_price |
|----------|------------|----------|------------|
| 1001     | 10         | 2        | 100000     |
| 1001     | 11         | 1        | 300000     |
| 1003     | 12         | 4        | 200000     |

## 3. SELECT: lấy cột cần dùng

Cú pháp cơ bản:

```sql
SELECT customer_id, full_name, city
FROM customers;
```

Không nên dùng `SELECT *` trong pipeline production:

```sql
SELECT *
FROM customers;
```

Vấn đề của `SELECT *`:

- Lấy nhiều dữ liệu hơn cần thiết.
- Tốn network, memory, I/O.
- Dễ vỡ pipeline nếu source thêm/xóa/sửa cột.
- Khó review logic vì không biết query thật sự cần cột nào.

Viết tốt hơn:

```sql
SELECT
  customer_id,
  full_name,
  city
FROM customers;
```

Tư duy senior: luôn chọn cột có chủ đích.

## 4. WHERE: lọc dữ liệu

Ví dụ lấy đơn hàng đã thanh toán:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM orders
WHERE status = 'PAID';
```

Lọc theo ngày:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM orders
WHERE order_date >= TIMESTAMP '2026-05-01 00:00:00'
  AND order_date <  TIMESTAMP '2026-06-01 00:00:00';
```

Không nên viết:

```sql
WHERE TO_CHAR(order_date, 'YYYY-MM') = '2026-05'
```

Vì dùng function trên cột ngày có thể làm database khó dùng index hoặc partition pruning.

## 5. AND, OR và dấu ngoặc

Sai logic phổ biến:

```sql
SELECT *
FROM orders
WHERE status = 'PAID'
   OR status = 'PENDING'
  AND total_amount >= 500000;
```

SQL ưu tiên `AND` trước `OR`, nên câu trên tương đương:

```sql
WHERE status = 'PAID'
   OR (status = 'PENDING' AND total_amount >= 500000)
```

Nếu muốn lấy đơn `PAID` hoặc `PENDING`, và đều phải có giá trị từ 500000:

```sql
SELECT *
FROM orders
WHERE status IN ('PAID', 'PENDING')
  AND total_amount >= 500000;
```

Tư duy senior: khi có cả `AND` và `OR`, nên dùng ngoặc rõ ràng.

## 6. ORDER BY: sắp xếp kết quả

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM orders
WHERE status = 'PAID'
ORDER BY order_date DESC;
```

Lưu ý:

- Không có `ORDER BY` thì database không đảm bảo thứ tự kết quả.
- `ORDER BY` trên dữ liệu lớn có thể tốn tài nguyên.
- Trong pipeline, chỉ dùng `ORDER BY` khi thật sự cần.

## 7. DISTINCT: loại trùng, nhưng không dùng để che lỗi

Ví dụ lấy danh sách thành phố:

```sql
SELECT DISTINCT city
FROM customers;
```

`DISTINCT` hợp lý khi mục tiêu là lấy danh sách giá trị duy nhất.

Không nên dùng `DISTINCT` để che lỗi join:

```sql
SELECT DISTINCT c.customer_id, c.full_name
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id;
```

Nếu join sinh trùng, phải hiểu vì sao trùng:

- Một customer có nhiều order.
- Join key không unique.
- Thiếu điều kiện join.
- Dữ liệu source bị duplicate.

Tư duy senior: duplicate là tín hiệu cần kiểm tra, không phải thứ để xóa vội bằng `DISTINCT`.

## 8. NULL: phần fresher rất hay sai

`NULL` nghĩa là không có giá trị hoặc không biết giá trị. `NULL` không bằng bất kỳ giá trị nào, kể cả chính nó.

Sai:

```sql
SELECT *
FROM customers
WHERE email = NULL;
```

Đúng:

```sql
SELECT *
FROM customers
WHERE email IS NULL;
```

Sai:

```sql
SELECT *
FROM orders
WHERE status <> 'CANCELLED';
```

Câu trên không lấy dòng có `status IS NULL`.

Nếu muốn lấy cả `NULL`:

```sql
SELECT *
FROM orders
WHERE status <> 'CANCELLED'
   OR status IS NULL;
```

## 9. CASE WHEN: tạo logic điều kiện

Ví dụ phân loại đơn hàng:

```sql
SELECT
  order_id,
  total_amount,
  CASE
    WHEN total_amount >= 1000000 THEN 'HIGH'
    WHEN total_amount >= 500000 THEN 'MEDIUM'
    ELSE 'LOW'
  END AS order_value_group
FROM orders;
```

Ví dụ chuẩn hóa trạng thái:

```sql
SELECT
  order_id,
  CASE
    WHEN status = 'PAID' THEN 'SUCCESS'
    WHEN status = 'CANCELLED' THEN 'FAILED'
    WHEN status = 'PENDING' THEN 'WAITING'
    ELSE 'UNKNOWN'
  END AS normalized_status
FROM orders;
```

Lưu ý:

- Thứ tự `WHEN` rất quan trọng.
- Luôn nghĩ về nhánh `ELSE`.
- Nếu thiếu `ELSE`, kết quả có thể là `NULL`.

## 10. IN, BETWEEN, LIKE

### IN

```sql
SELECT *
FROM orders
WHERE status IN ('PAID', 'PENDING');
```

### BETWEEN

```sql
SELECT *
FROM orders
WHERE total_amount BETWEEN 500000 AND 1000000;
```

Lưu ý: `BETWEEN` bao gồm cả hai đầu.

Với timestamp, nên tránh dùng:

```sql
WHERE order_date BETWEEN TIMESTAMP '2026-05-01 00:00:00'
                     AND TIMESTAMP '2026-05-31 00:00:00'
```

Vì sẽ bỏ sót dữ liệu trong ngày `2026-05-31` sau 00:00:00.

Nên viết:

```sql
WHERE order_date >= TIMESTAMP '2026-05-01 00:00:00'
  AND order_date <  TIMESTAMP '2026-06-01 00:00:00'
```

### LIKE

```sql
SELECT *
FROM customers
WHERE email LIKE '%@example.com';
```

Lưu ý:

- `LIKE 'abc%'` thường dễ tối ưu hơn.
- `LIKE '%abc%'` thường khó dùng B-tree index hiệu quả.

## 11. Hàm xử lý chuỗi, số, ngày

Ví dụ xử lý chuỗi:

```sql
SELECT
  customer_id,
  UPPER(email) AS email_upper,
  LOWER(city) AS city_lower
FROM customers;
```

Ví dụ xử lý số:

```sql
SELECT
  order_id,
  total_amount,
  ROUND(total_amount / 1000000, 2) AS amount_million
FROM orders;
```

Ví dụ xử lý ngày:

```sql
SELECT
  order_id,
  order_date,
  EXTRACT(YEAR FROM order_date) AS order_year,
  EXTRACT(MONTH FROM order_date) AS order_month
FROM orders;
```

Tư duy senior: dùng function trong `SELECT` thường ổn, nhưng dùng function trên cột trong `WHERE` cần cẩn thận vì ảnh hưởng performance.

## 12. LIMIT, FETCH FIRST, ROWNUM

Tùy database, cú pháp lấy một số dòng đầu khác nhau.

PostgreSQL/MySQL:

```sql
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 10;
```

Oracle 12c+:

```sql
SELECT *
FROM orders
ORDER BY order_date DESC
FETCH FIRST 10 ROWS ONLY;
```

Oracle cũ:

```sql
SELECT *
FROM (
  SELECT *
  FROM orders
  ORDER BY order_date DESC
)
WHERE ROWNUM <= 10;
```

## 13. Comment SQL

Comment một dòng:

```sql
-- Lấy đơn hàng đã thanh toán trong tháng 5/2026
SELECT *
FROM orders
WHERE status = 'PAID';
```

Comment nhiều dòng:

```sql
/*
  Query này dùng để đối soát doanh thu theo đơn hàng.
  Chỉ tính các đơn PAID.
*/
SELECT *
FROM orders
WHERE status = 'PAID';
```

Comment tốt nên giải thích "vì sao", không chỉ nhắc lại "làm gì".

## 14. Style SQL dễ đọc

Nên viết:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-06-01'
ORDER BY order_date DESC;
```

Không nên viết:

```sql
select order_id,customer_id,order_date,total_amount from orders where status='PAID' and order_date>=date '2026-05-01' and order_date<date '2026-06-01' order by order_date desc;
```

Senior không chỉ viết SQL chạy được, mà viết để người khác review được.

## 15. Lỗi fresher hay gặp

- Dùng `SELECT *` mọi nơi.
- Quên điều kiện ngày dạng nửa mở: `>= start` và `< next_day`.
- So sánh `NULL` bằng `= NULL`.
- Dùng `DISTINCT` để che duplicate.
- Không dùng alias rõ ràng.
- Không format SQL.
- Không nghĩ về timezone.
- Không kiểm tra số dòng trước/sau filter.
- Dùng string để so sánh với date hoặc number.

## 16. Checklist trước khi gửi SQL

Trước khi đưa SQL vào pipeline hoặc gửi review:

- Query có chọn đúng cột cần dùng không?
- Điều kiện `WHERE` có đúng logic không?
- Có xử lý `NULL` chưa?
- Có dùng `DISTINCT` không? Nếu có, vì sao?
- Có filter theo partition/date nếu bảng lớn không?
- Có dùng function trên cột filter không?
- Kết quả trả về bao nhiêu dòng?
- Query có dễ đọc không?
- Có test với dữ liệu biên chưa?

## 17. Bài tập tự luyện

### Bài 1

Viết query lấy danh sách đơn hàng đã thanh toán trong tháng 5/2026, gồm:

- `order_id`
- `customer_id`
- `order_date`
- `total_amount`

### Bài 2

Viết query phân loại đơn hàng:

- `HIGH` nếu `total_amount >= 1000000`
- `MEDIUM` nếu `total_amount >= 500000`
- `LOW` nếu còn lại

### Bài 3

Viết query lấy customer chưa có email.

### Bài 4

Viết query lấy các đơn hàng không phải `CANCELLED`, bao gồm cả đơn có `status IS NULL`.

### Bài 5

Giải thích vì sao câu sau có thể sai:

```sql
SELECT DISTINCT customer_id
FROM orders;
```

Gợi ý: bản thân câu SQL không sai, nhưng có thể không trả lời đúng câu hỏi nghiệp vụ nếu cần biết mỗi customer có bao nhiêu đơn hoặc đơn mới nhất là đơn nào.

## 18. Từ fresher lên senior ở phần nền tảng

Fresher thường hỏi: "Câu SQL này chạy được chưa?"

Senior hỏi:

- Kết quả có đúng nghĩa nghiệp vụ không?
- Có bị mất dòng do `NULL` không?
- Có bị sai do date/time không?
- Có lấy dư dữ liệu không?
- Có dễ bảo trì không?
- Khi dữ liệu tăng 100 lần, query này còn ổn không?

Đó là khác biệt lớn nhất.

