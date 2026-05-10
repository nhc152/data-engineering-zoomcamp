# Phần 4: Window Functions

Mục tiêu của phần này: giúp bạn dùng window functions để giải các bài toán phân tích thường gặp như dedup, lấy bản ghi mới nhất, ranking, running total, moving average, retention và sessionization cơ bản.

## 1. Window function là gì?

Window function tính toán trên một "cửa sổ" các dòng liên quan đến dòng hiện tại, nhưng không làm giảm số dòng như `GROUP BY`.

So sánh:

`GROUP BY` gom nhiều dòng thành ít dòng hơn.

```sql
SELECT
  customer_id,
  COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;
```

Window function giữ nguyên số dòng, nhưng thêm thông tin tính toán:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  COUNT(*) OVER (PARTITION BY customer_id) AS order_count_of_customer
FROM orders;
```

## 2. Cấu trúc cơ bản

```sql
function_name(...) OVER (
  PARTITION BY ...
  ORDER BY ...
  ROWS BETWEEN ... AND ...
)
```

Ý nghĩa:

- `PARTITION BY`: chia dữ liệu thành nhóm.
- `ORDER BY`: sắp xếp trong từng nhóm.
- Frame clause: xác định phạm vi dòng để tính.

Không phải lúc nào cũng cần đủ cả ba phần.

## 3. ROW_NUMBER

`ROW_NUMBER` đánh số thứ tự từng dòng trong mỗi partition.

Lấy order mới nhất của mỗi customer:

```sql
WITH ranked_orders AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date DESC, order_id DESC
    ) AS rn
  FROM orders
)
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount
FROM ranked_orders
WHERE rn = 1;
```

Tại sao thêm `order_id DESC`?

Nếu hai order có cùng `order_date`, cần tie-breaker để kết quả ổn định.

Tư duy senior: ranking cần deterministic order, tức là thứ tự phải rõ ràng.

## 4. Dedup dữ liệu

Ví dụ bảng staging có nhiều bản ghi cho cùng `customer_id`, cần lấy bản ghi mới nhất.

```sql
WITH dedup AS (
  SELECT
    customer_id,
    full_name,
    email,
    updated_at,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY updated_at DESC
    ) AS rn
  FROM stg_customers
)
SELECT
  customer_id,
  full_name,
  email,
  updated_at
FROM dedup
WHERE rn = 1;
```

Nếu `updated_at` có thể trùng, thêm tie-breaker:

```sql
ORDER BY updated_at DESC, ingestion_id DESC
```

Lỗi thường gặp: dedup không deterministic, mỗi lần chạy có thể lấy record khác.

## 5. RANK và DENSE_RANK

`RANK` và `DENSE_RANK` dùng để xếp hạng có xử lý đồng hạng.

Ví dụ:

| customer_id | revenue |
|-------------|---------|
| 1           | 1000    |
| 2           | 800     |
| 3           | 800     |
| 4           | 500     |

`RANK`:

| customer_id | revenue | rank |
|-------------|---------|------|
| 1           | 1000    | 1    |
| 2           | 800     | 2    |
| 3           | 800     | 2    |
| 4           | 500     | 4    |

`DENSE_RANK`:

| customer_id | revenue | dense_rank |
|-------------|---------|------------|
| 1           | 1000    | 1          |
| 2           | 800     | 2          |
| 3           | 800     | 2          |
| 4           | 500     | 3          |

Query:

```sql
WITH customer_revenue AS (
  SELECT
    customer_id,
    SUM(total_amount) AS revenue
  FROM orders
  WHERE status = 'PAID'
  GROUP BY customer_id
)
SELECT
  customer_id,
  revenue,
  RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
  DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_revenue_rank
FROM customer_revenue;
```

## 6. Top N per group

Lấy 3 order lớn nhất của mỗi customer:

```sql
WITH ranked AS (
  SELECT
    order_id,
    customer_id,
    total_amount,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY total_amount DESC, order_id DESC
    ) AS rn
  FROM orders
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

Nếu muốn lấy cả đồng hạng, dùng `RANK` hoặc `DENSE_RANK`.

## 7. LAG và LEAD

`LAG` lấy giá trị dòng trước. `LEAD` lấy giá trị dòng sau.

Ví dụ so sánh order hiện tại với order trước đó của cùng customer:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  total_amount,
  LAG(order_date) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS previous_order_date,
  LAG(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS previous_order_amount
FROM orders;
```

Tính số ngày giữa hai lần mua:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  order_date - LAG(order_date) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS days_since_previous_order
FROM orders;
```

Cú pháp trừ ngày khác nhau tùy database. Oracle trả về số ngày khi trừ hai `DATE`.

## 8. FIRST_VALUE và LAST_VALUE

Lấy order đầu tiên của customer:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  FIRST_VALUE(order_date) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS first_order_date
FROM orders;
```

Cẩn thận với `LAST_VALUE`. Nhiều database mặc định frame chỉ đến dòng hiện tại, nên `LAST_VALUE` có thể trả về chính dòng hiện tại.

Nên viết rõ frame:

```sql
SELECT
  order_id,
  customer_id,
  order_date,
  LAST_VALUE(order_date) OVER (
    PARTITION BY customer_id
    ORDER BY order_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_order_date
FROM orders;
```

## 9. Running total

Tính doanh thu lũy kế theo ngày:

```sql
WITH daily_revenue AS (
  SELECT
    CAST(order_date AS DATE) AS order_day,
    SUM(total_amount) AS revenue
  FROM orders
  WHERE status = 'PAID'
  GROUP BY CAST(order_date AS DATE)
)
SELECT
  order_day,
  revenue,
  SUM(revenue) OVER (
    ORDER BY order_day
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_revenue
FROM daily_revenue
ORDER BY order_day;
```

Ứng dụng:

- Doanh thu lũy kế tháng.
- Số user đăng ký lũy kế.
- Tổng giao dịch lũy kế.

## 10. Moving average

Tính trung bình doanh thu 7 ngày:

```sql
WITH daily_revenue AS (
  SELECT
    CAST(order_date AS DATE) AS order_day,
    SUM(total_amount) AS revenue
  FROM orders
  WHERE status = 'PAID'
  GROUP BY CAST(order_date AS DATE)
)
SELECT
  order_day,
  revenue,
  AVG(revenue) OVER (
    ORDER BY order_day
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS moving_avg_7d
FROM daily_revenue
ORDER BY order_day;
```

Lưu ý:

- Nếu thiếu ngày không có order, moving average có thể sai vì chỉ tính ngày có dữ liệu.
- Nên join với bảng calendar để có đủ ngày.

## 11. SUM OVER theo partition

Tính tỷ trọng mỗi order trong tổng doanh thu customer:

```sql
SELECT
  order_id,
  customer_id,
  total_amount,
  SUM(total_amount) OVER (
    PARTITION BY customer_id
  ) AS customer_total_amount,
  1.0 * total_amount / SUM(total_amount) OVER (
    PARTITION BY customer_id
  ) AS order_share
FROM orders
WHERE status = 'PAID';
```

Lưu ý tránh chia cho 0 nếu tổng có thể bằng 0.

## 12. QUALIFY

Một số database như BigQuery, Snowflake hỗ trợ `QUALIFY`, giúp filter trực tiếp trên window function.

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

Nếu database không hỗ trợ `QUALIFY`, dùng CTE:

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

## 13. Minh họa thực tế: lấy record mới nhất trong CDC

Tình huống:

Bảng `stg_customer_cdc` nhận nhiều event thay đổi customer:

| customer_id | full_name | email | operation | event_time |
|-------------|-----------|-------|-----------|------------|
| 1           | An        | a@x   | INSERT    | 10:00      |
| 1           | An N.     | a@x   | UPDATE    | 10:05      |
| 1           | An N.     | a@x   | DELETE    | 10:10      |

Cần lấy trạng thái mới nhất cho mỗi customer:

```sql
WITH latest AS (
  SELECT
    customer_id,
    full_name,
    email,
    operation,
    event_time,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY event_time DESC
    ) AS rn
  FROM stg_customer_cdc
)
SELECT
  customer_id,
  full_name,
  email,
  operation,
  event_time
FROM latest
WHERE rn = 1;
```

Nếu muốn loại customer đã bị xóa:

```sql
WITH latest AS (
  SELECT
    customer_id,
    full_name,
    email,
    operation,
    event_time,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY event_time DESC
    ) AS rn
  FROM stg_customer_cdc
)
SELECT
  customer_id,
  full_name,
  email
FROM latest
WHERE rn = 1
  AND operation <> 'DELETE';
```

## 14. Sessionization cơ bản

Tình huống:

Mỗi event của user có `event_time`. Nếu khoảng cách giữa hai event lớn hơn 30 phút thì bắt đầu session mới.

```sql
WITH events_with_prev AS (
  SELECT
    user_id,
    event_time,
    event_name,
    LAG(event_time) OVER (
      PARTITION BY user_id
      ORDER BY event_time
    ) AS prev_event_time
  FROM events
),
session_flags AS (
  SELECT
    user_id,
    event_time,
    event_name,
    CASE
      WHEN prev_event_time IS NULL THEN 1
      WHEN event_time > prev_event_time + INTERVAL '30' MINUTE THEN 1
      ELSE 0
    END AS is_new_session
  FROM events_with_prev
),
sessions AS (
  SELECT
    user_id,
    event_time,
    event_name,
    SUM(is_new_session) OVER (
      PARTITION BY user_id
      ORDER BY event_time
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS session_number
  FROM session_flags
)
SELECT *
FROM sessions;
```

Cú pháp interval có thể khác nhau tùy database.

## 15. Lỗi window function phổ biến

- Quên `PARTITION BY`, làm tính trên toàn bộ bảng.
- Thiếu `ORDER BY` khi dùng ranking.
- Order không deterministic, thiếu tie-breaker.
- Dùng `LAST_VALUE` nhưng không khai báo frame đúng.
- Dùng window trên dữ liệu chưa aggregate đúng grain.
- Tính moving average nhưng thiếu ngày không có dữ liệu.
- Dùng window function thay cho aggregate trong khi chỉ cần aggregate.

## 16. Checklist window function

- Mỗi dòng kết quả đại diện cho gì?
- Có cần giữ nguyên số dòng không?
- Partition theo cột nào?
- Order theo cột nào?
- Có tie-breaker chưa?
- Frame có đúng không?
- Có cần dedup trước không?
- Có cần aggregate trước không?
- Database có hỗ trợ `QUALIFY` không?

## 17. Bài tập tự luyện

### Bài 1

Lấy order mới nhất của mỗi customer.

### Bài 2

Tìm 3 customer có doanh thu cao nhất.

### Bài 3

Tính số ngày giữa hai lần mua liên tiếp của mỗi customer.

### Bài 4

Tính doanh thu lũy kế theo ngày.

### Bài 5

Dedup bảng `stg_customers` theo `customer_id`, lấy record có `updated_at` mới nhất.

## 18. Từ fresher lên senior ở phần window functions

Fresher thường dùng window function như công thức.

Senior hiểu rõ:

- Dữ liệu đang ở grain nào.
- Có cần aggregate trước không.
- Ranking có deterministic không.
- Frame mặc định có gây sai không.
- Query có chạy được trên dữ liệu lớn không.

Window functions là công cụ rất mạnh. Dùng đúng sẽ làm SQL gọn và rõ. Dùng sai sẽ tạo ra kết quả nhìn hợp lý nhưng sai âm thầm.

