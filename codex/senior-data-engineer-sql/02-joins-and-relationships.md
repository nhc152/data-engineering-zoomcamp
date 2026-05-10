# Phần 2: JOIN và quan hệ dữ liệu

Mục tiêu của phần này: giúp bạn hiểu join không chỉ là ghép bảng, mà là nơi rất dễ làm sai dữ liệu. Với Data Engineer, lỗi join có thể làm doanh thu tăng gấp đôi, user count bị sai, hoặc pipeline sinh duplicate.

## 1. JOIN là gì?

`JOIN` dùng để kết hợp dữ liệu từ nhiều bảng dựa trên một hoặc nhiều điều kiện liên kết.

Ví dụ:

```sql
SELECT
  o.order_id,
  o.order_date,
  c.customer_id,
  c.full_name
FROM orders o
JOIN customers c
  ON c.customer_id = o.customer_id;
```

Câu trên lấy thông tin đơn hàng kèm thông tin khách hàng.

## 2. Grain: khái niệm quan trọng trước khi join

Grain nghĩa là "mỗi dòng trong bảng đại diện cho điều gì".

Ví dụ:

- `customers`: mỗi dòng là một customer.
- `orders`: mỗi dòng là một order.
- `order_items`: mỗi dòng là một sản phẩm trong một order.
- `events`: mỗi dòng là một event người dùng.

Trước khi join, phải biết grain của từng bảng.

Nếu không biết grain, rất dễ nhân dòng.

Ví dụ:

```sql
SELECT
  o.order_id,
  o.total_amount,
  i.product_id
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id;
```

Nếu order `1001` có 2 items, dòng order `1001` sẽ xuất hiện 2 lần.

Điều này đúng nếu bạn muốn dữ liệu ở grain `order item`, nhưng sai nếu bạn vẫn nghĩ mỗi dòng là một order.

## 3. INNER JOIN

`INNER JOIN` chỉ lấy dòng khớp ở cả hai bảng.

```sql
SELECT
  o.order_id,
  c.full_name
FROM orders o
INNER JOIN customers c
  ON c.customer_id = o.customer_id;
```

Nếu `orders.customer_id` không tìm thấy trong `customers`, dòng order đó sẽ bị loại.

Phù hợp khi:

- Chỉ muốn dữ liệu có đủ hai phía.
- Dữ liệu referential integrity đảm bảo đầy đủ.

Rủi ro:

- Có thể làm mất dữ liệu nếu dimension thiếu record.

Ví dụ thực tế:

Fact order có `customer_id = 999`, nhưng `dim_customer` chưa load kịp. Dùng `INNER JOIN` sẽ làm mất order này trong báo cáo.

## 4. LEFT JOIN

`LEFT JOIN` giữ toàn bộ dòng bên trái, dù bên phải không khớp.

```sql
SELECT
  o.order_id,
  o.customer_id,
  c.full_name
FROM orders o
LEFT JOIN customers c
  ON c.customer_id = o.customer_id;
```

Nếu không có customer tương ứng, `c.full_name` sẽ là `NULL`.

Phù hợp khi:

- Muốn giữ toàn bộ fact.
- Muốn kiểm tra missing dimension.
- Muốn tìm dữ liệu không có match.

Ví dụ tìm order không có customer:

```sql
SELECT
  o.order_id,
  o.customer_id
FROM orders o
LEFT JOIN customers c
  ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;
```

Đây là một query data quality rất phổ biến.

## 5. RIGHT JOIN và FULL JOIN

`RIGHT JOIN` giữ toàn bộ bảng bên phải. Thường có thể viết lại thành `LEFT JOIN` bằng cách đổi thứ tự bảng.

```sql
SELECT
  o.order_id,
  c.customer_id
FROM orders o
RIGHT JOIN customers c
  ON c.customer_id = o.customer_id;
```

Thường dễ đọc hơn khi viết:

```sql
SELECT
  o.order_id,
  c.customer_id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id;
```

`FULL JOIN` giữ dữ liệu cả hai phía:

```sql
SELECT
  o.order_id,
  c.customer_id
FROM orders o
FULL JOIN customers c
  ON c.customer_id = o.customer_id;
```

Phù hợp để đối soát hai nguồn dữ liệu.

## 6. CROSS JOIN và Cartesian product

`CROSS JOIN` kết hợp mỗi dòng bảng A với mỗi dòng bảng B.

```sql
SELECT
  c.customer_id,
  d.report_date
FROM customers c
CROSS JOIN calendar_dates d;
```

Nếu có 1,000 customers và 365 dates, kết quả là 365,000 dòng.

Có lúc cần dùng, ví dụ tạo khung customer-date để tính daily activity.

Nhưng nếu vô tình quên điều kiện join:

```sql
SELECT *
FROM orders o
JOIN customers c;
```

hoặc:

```sql
SELECT *
FROM orders o, customers c;
```

thì có thể sinh Cartesian product cực lớn.

## 7. Join 1-1, 1-n, n-n

### 1-1

Mỗi dòng bảng A khớp tối đa một dòng bảng B.

Ví dụ:

- `users`
- `user_profiles`

### 1-n

Một dòng bảng A khớp nhiều dòng bảng B.

Ví dụ:

- Một customer có nhiều orders.
- Một order có nhiều order_items.

### n-n

Nhiều dòng A khớp nhiều dòng B. Thường cần bảng bridge.

Ví dụ:

- Student và course.
- Product và promotion.

Bảng bridge:

```text
student_courses(student_id, course_id)
```

Senior phải nhìn ra cardinality trước khi aggregate.

## 8. Duplicate sau join

Ví dụ sai:

```sql
SELECT
  c.customer_id,
  c.full_name,
  SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN order_items i
  ON i.order_id = o.order_id
GROUP BY c.customer_id, c.full_name;
```

Vấn đề:

- `orders` join với `order_items` làm mỗi order bị lặp theo số items.
- `SUM(o.total_amount)` có thể bị nhân lên.

Cách đúng nếu muốn revenue theo order:

```sql
SELECT
  c.customer_id,
  c.full_name,
  SUM(o.total_amount) AS total_revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;
```

Nếu cần tính từ item:

```sql
SELECT
  c.customer_id,
  c.full_name,
  SUM(i.quantity * i.unit_price) AS total_revenue
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id
JOIN order_items i
  ON i.order_id = o.order_id
GROUP BY c.customer_id, c.full_name;
```

Tư duy senior: aggregate phải phù hợp với grain sau join.

## 9. Kiểm tra cardinality trước khi join

Kiểm tra key có unique không:

```sql
SELECT
  customer_id,
  COUNT(*) AS cnt
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Kiểm tra mỗi order có bao nhiêu item:

```sql
SELECT
  order_id,
  COUNT(*) AS item_count
FROM order_items
GROUP BY order_id
ORDER BY item_count DESC;
```

Kiểm tra số dòng trước/sau join:

```sql
SELECT COUNT(*) AS order_count
FROM orders;
```

```sql
SELECT COUNT(*) AS joined_count
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id;
```

Nếu `joined_count` lớn hơn `order_count`, đó có thể là đúng hoặc sai tùy grain mong muốn.

## 10. Semi join với EXISTS

Khi chỉ cần biết có tồn tại hay không, dùng `EXISTS`.

Ví dụ lấy customer đã từng mua hàng:

```sql
SELECT
  c.customer_id,
  c.full_name
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
);
```

Ưu điểm:

- Không nhân dòng customer.
- Thể hiện đúng ý định: kiểm tra tồn tại.

So với:

```sql
SELECT DISTINCT
  c.customer_id,
  c.full_name
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id;
```

Câu dùng `DISTINCT` có thể đúng kết quả nhưng kém rõ ý định hơn.

## 11. Anti join với NOT EXISTS

Lấy customer chưa từng mua hàng:

```sql
SELECT
  c.customer_id,
  c.full_name
FROM customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.customer_id = c.customer_id
);
```

Tránh dùng `NOT IN` nếu subquery có thể trả về `NULL`.

Rủi ro:

```sql
SELECT *
FROM customers
WHERE customer_id NOT IN (
  SELECT customer_id
  FROM orders
);
```

Nếu `orders.customer_id` có `NULL`, kết quả có thể không như mong đợi.

## 12. Điều kiện filter đặt ở ON hay WHERE

Với `INNER JOIN`, filter trong `ON` hoặc `WHERE` thường tương đương về kết quả.

Với `LEFT JOIN`, khác biệt rất quan trọng.

Ví dụ muốn lấy tất cả customers và chỉ join các order `PAID`:

```sql
SELECT
  c.customer_id,
  c.full_name,
  o.order_id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id
 AND o.status = 'PAID';
```

Câu này vẫn giữ customer không có order paid.

Nhưng nếu viết:

```sql
SELECT
  c.customer_id,
  c.full_name,
  o.order_id
FROM customers c
LEFT JOIN orders o
  ON o.customer_id = c.customer_id
WHERE o.status = 'PAID';
```

Thì `LEFT JOIN` gần như biến thành `INNER JOIN`, vì dòng không có order sẽ có `o.status IS NULL` và bị loại.

Đây là lỗi rất phổ biến.

## 13. Join nhiều cột

Khi key gồm nhiều cột, phải join đủ.

Ví dụ bảng `daily_customer_balance` có key:

```text
customer_id, balance_date
```

Join sai:

```sql
SELECT *
FROM daily_customer_balance b
JOIN daily_customer_status s
  ON s.customer_id = b.customer_id;
```

Join đúng:

```sql
SELECT *
FROM daily_customer_balance b
JOIN daily_customer_status s
  ON s.customer_id = b.customer_id
 AND s.status_date = b.balance_date;
```

Thiếu một cột key có thể làm nhân dòng dữ liệu.

## 14. Join khác kiểu dữ liệu

Không nên:

```sql
SELECT *
FROM orders o
JOIN customers c
  ON c.customer_id = TO_NUMBER(o.customer_id_text);
```

Vấn đề:

- Có thể lỗi nếu dữ liệu không convert được.
- Có thể làm giảm khả năng dùng index.
- Cho thấy model dữ liệu chưa sạch.

Nên chuẩn hóa kiểu dữ liệu từ staging:

```sql
CAST(customer_id_text AS NUMBER) AS customer_id
```

rồi lưu vào cột đúng kiểu trước khi join.

## 15. Minh họa thực tế: dashboard doanh thu bị gấp đôi

Tình huống:

Business báo dashboard doanh thu tháng 5 cao bất thường.

Query hiện tại:

```sql
SELECT
  DATE_TRUNC('month', o.order_date) AS month,
  SUM(o.total_amount) AS revenue
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id
WHERE o.status = 'PAID'
GROUP BY DATE_TRUNC('month', o.order_date);
```

Nguyên nhân:

- Một order có nhiều item.
- Join với `order_items` làm order bị lặp.
- `SUM(o.total_amount)` bị cộng nhiều lần.

Cách sửa 1: không join nếu không cần item.

```sql
SELECT
  DATE_TRUNC('month', o.order_date) AS month,
  SUM(o.total_amount) AS revenue
FROM orders o
WHERE o.status = 'PAID'
GROUP BY DATE_TRUNC('month', o.order_date);
```

Cách sửa 2: nếu cần revenue từ item.

```sql
SELECT
  DATE_TRUNC('month', o.order_date) AS month,
  SUM(i.quantity * i.unit_price) AS revenue
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id
WHERE o.status = 'PAID'
GROUP BY DATE_TRUNC('month', o.order_date);
```

Senior lesson: trước khi aggregate sau join, phải biết grain đã thay đổi chưa.

## 16. Checklist khi viết JOIN

- Grain của từng bảng là gì?
- Join key có unique ở phía cần unique không?
- Đây là quan hệ 1-1, 1-n hay n-n?
- Sau join số dòng tăng/giảm có hợp lý không?
- Dùng `INNER JOIN` có làm mất dữ liệu không?
- Dùng `LEFT JOIN` rồi filter bảng phải trong `WHERE` có làm sai logic không?
- Có thiếu cột trong composite key không?
- Có join khác kiểu dữ liệu không?
- Có dùng `DISTINCT` để che lỗi không?
- Aggregate sau join có bị nhân số không?

## 17. Bài tập tự luyện

### Bài 1

Viết query lấy tất cả orders kèm tên customer. Nếu customer bị thiếu trong bảng `customers`, vẫn phải giữ order.

### Bài 2

Viết query tìm các customer chưa từng có order.

### Bài 3

Viết query tính revenue theo customer, biết revenue lấy từ `orders.total_amount`, không được để order bị nhân dòng.

### Bài 4

Viết query kiểm tra customer_id trong bảng `customers` có bị duplicate không.

### Bài 5

Giải thích vì sao câu sau có thể làm sai doanh thu:

```sql
SELECT SUM(o.total_amount)
FROM orders o
JOIN order_items i
  ON i.order_id = o.order_id;
```

## 18. Từ fresher lên senior ở phần JOIN

Fresher thường nghĩ: "Join ra được dữ liệu là xong."

Senior nghĩ:

- Join này có làm thay đổi grain không?
- Có nhân dòng không?
- Có làm mất dòng không?
- Có dùng đúng join type không?
- Aggregate sau join có còn đúng không?
- Có kiểm tra row count trước/sau join không?

JOIN là nơi SQL nhìn đơn giản nhưng rủi ro rất cao. Muốn lên senior, phải cực kỳ nhạy với grain và cardinality.

