# Phần 11: SQL cho Analytical Use Cases

Mục tiêu của phần này: giúp bạn dùng SQL để giải các bài toán phân tích thường gặp trong công việc như DAU, MAU, funnel, retention, cohort, churn, revenue metrics và rolling metrics.

## 1. Analytical SQL là gì?

Analytical SQL là SQL dùng để trả lời câu hỏi kinh doanh.

Ví dụ:

- Hôm nay có bao nhiêu active users?
- Tỷ lệ chuyển đổi từ view product sang purchase là bao nhiêu?
- User quay lại sau 7 ngày là bao nhiêu phần trăm?
- Doanh thu tháng này tăng hay giảm so với tháng trước?
- Nhóm user đăng ký tháng 1 có retention như thế nào?

Senior Data Engineer cần biết biến câu hỏi business thành metric rõ ràng, rồi viết SQL đúng với định nghĩa đó.

## 2. Bảng ví dụ: events

| event_id | user_id | event_name   | event_time          |
|----------|---------|--------------|---------------------|
| 1        | 101     | app_open     | 2026-05-01 08:00:00 |
| 2        | 101     | view_product | 2026-05-01 08:01:00 |
| 3        | 101     | purchase     | 2026-05-01 08:05:00 |
| 4        | 102     | app_open     | 2026-05-01 09:00:00 |
| 5        | 102     | view_product | 2026-05-01 09:03:00 |

Các cột thường có trong event table:

- `event_id`
- `user_id`
- `session_id`
- `event_name`
- `event_time`
- `event_date`
- `device_type`
- `platform`
- `country`
- `properties`

## 3. DAU, WAU, MAU

DAU là daily active users.

```sql
SELECT
  CAST(event_time AS DATE) AS event_date,
  COUNT(DISTINCT user_id) AS dau
FROM events
WHERE event_name = 'app_open'
GROUP BY CAST(event_time AS DATE)
ORDER BY event_date;
```

MAU là monthly active users.

```sql
SELECT
  DATE_TRUNC('month', event_time) AS event_month,
  COUNT(DISTINCT user_id) AS mau
FROM events
WHERE event_name = 'app_open'
GROUP BY DATE_TRUNC('month', event_time)
ORDER BY event_month;
```

Lưu ý:

- Định nghĩa active user phải rõ.
- Có hệ thống tính active bằng `app_open`.
- Có hệ thống tính active bằng bất kỳ event nào.
- Có hệ thống loại bot/test users.

## 4. Conversion rate

Ví dụ tính tỷ lệ user purchase trong số user đã view product.

```sql
WITH user_flags AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_name = 'view_product' THEN 1 ELSE 0 END) AS has_view_product,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS has_purchase
  FROM events
  WHERE event_time >= DATE '2026-05-01'
    AND event_time <  DATE '2026-06-01'
  GROUP BY user_id
)
SELECT
  SUM(has_view_product) AS view_users,
  SUM(CASE WHEN has_view_product = 1 AND has_purchase = 1 THEN 1 ELSE 0 END) AS purchase_users,
  1.0 * SUM(CASE WHEN has_view_product = 1 AND has_purchase = 1 THEN 1 ELSE 0 END)
    / NULLIF(SUM(has_view_product), 0) AS conversion_rate
FROM user_flags;
```

Điểm cần rõ:

- Conversion tính theo user, session hay event?
- Purchase có phải xảy ra sau view không?
- Có giới hạn thời gian conversion không?

## 5. Funnel analysis

Funnel ví dụ:

```text
app_open -> view_product -> add_to_cart -> purchase
```

Đếm user đi qua từng bước:

```sql
WITH user_steps AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_name = 'app_open' THEN event_time END) AS app_open_time,
    MIN(CASE WHEN event_name = 'view_product' THEN event_time END) AS view_product_time,
    MIN(CASE WHEN event_name = 'add_to_cart' THEN event_time END) AS add_to_cart_time,
    MIN(CASE WHEN event_name = 'purchase' THEN event_time END) AS purchase_time
  FROM events
  WHERE event_time >= DATE '2026-05-01'
    AND event_time <  DATE '2026-06-01'
  GROUP BY user_id
),
valid_steps AS (
  SELECT
    user_id,
    app_open_time,
    CASE
      WHEN view_product_time > app_open_time THEN view_product_time
    END AS view_product_time,
    CASE
      WHEN add_to_cart_time > view_product_time THEN add_to_cart_time
    END AS add_to_cart_time,
    CASE
      WHEN purchase_time > add_to_cart_time THEN purchase_time
    END AS purchase_time
  FROM user_steps
)
SELECT
  COUNT(CASE WHEN app_open_time IS NOT NULL THEN 1 END) AS step_app_open,
  COUNT(CASE WHEN view_product_time IS NOT NULL THEN 1 END) AS step_view_product,
  COUNT(CASE WHEN add_to_cart_time IS NOT NULL THEN 1 END) AS step_add_to_cart,
  COUNT(CASE WHEN purchase_time IS NOT NULL THEN 1 END) AS step_purchase
FROM valid_steps;
```

Lưu ý: funnel nghiêm túc cần kiểm tra thứ tự event và cửa sổ thời gian.

## 6. Retention analysis

Retention trả lời: user quay lại sau N ngày không?

Ví dụ D1 retention:

```sql
WITH first_seen AS (
  SELECT
    user_id,
    MIN(CAST(event_time AS DATE)) AS first_date
  FROM events
  GROUP BY user_id
),
activity AS (
  SELECT DISTINCT
    user_id,
    CAST(event_time AS DATE) AS active_date
  FROM events
)
SELECT
  f.first_date,
  COUNT(*) AS cohort_users,
  COUNT(a.user_id) AS retained_d1_users,
  1.0 * COUNT(a.user_id) / NULLIF(COUNT(*), 0) AS d1_retention
FROM first_seen f
LEFT JOIN activity a
  ON a.user_id = f.user_id
 AND a.active_date = f.first_date + INTERVAL '1' DAY
GROUP BY f.first_date
ORDER BY f.first_date;
```

Tùy database, cộng ngày có cú pháp khác nhau.

## 7. Cohort analysis

Cohort là nhóm user có chung đặc điểm, thường là ngày/tháng đăng ký.

Ví dụ retention theo cohort month và activity month:

```sql
WITH user_cohort AS (
  SELECT
    user_id,
    DATE_TRUNC('month', MIN(event_time)) AS cohort_month
  FROM events
  GROUP BY user_id
),
monthly_activity AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('month', event_time) AS activity_month
  FROM events
),
cohort_activity AS (
  SELECT
    c.cohort_month,
    a.activity_month,
    MONTHS_BETWEEN(a.activity_month, c.cohort_month) AS month_number,
    COUNT(DISTINCT c.user_id) AS active_users
  FROM user_cohort c
  JOIN monthly_activity a
    ON a.user_id = c.user_id
   AND a.activity_month >= c.cohort_month
  GROUP BY c.cohort_month, a.activity_month
)
SELECT *
FROM cohort_activity
ORDER BY cohort_month, month_number;
```

`MONTHS_BETWEEN` là Oracle style. Database khác sẽ có hàm khác.

## 8. Churn analysis

Churn nghĩa là user rời bỏ hoặc không còn active.

Ví dụ user active trong tháng trước nhưng không active tháng này:

```sql
WITH monthly_users AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('month', event_time) AS active_month
  FROM events
),
prev_month AS (
  SELECT user_id
  FROM monthly_users
  WHERE active_month = DATE '2026-04-01'
),
curr_month AS (
  SELECT user_id
  FROM monthly_users
  WHERE active_month = DATE '2026-05-01'
)
SELECT
  COUNT(p.user_id) AS previous_users,
  COUNT(c.user_id) AS retained_users,
  COUNT(p.user_id) - COUNT(c.user_id) AS churned_users,
  1.0 * (COUNT(p.user_id) - COUNT(c.user_id)) / NULLIF(COUNT(p.user_id), 0) AS churn_rate
FROM prev_month p
LEFT JOIN curr_month c
  ON c.user_id = p.user_id;
```

Churn definition phải thống nhất với business.

## 9. Revenue metrics

Các metric phổ biến:

- Gross revenue.
- Net revenue.
- Refund amount.
- Average order value.
- Revenue per user.
- Monthly recurring revenue.

Ví dụ AOV:

```sql
SELECT
  CAST(order_date AS DATE) AS order_day,
  SUM(total_amount) AS revenue,
  COUNT(*) AS paid_orders,
  1.0 * SUM(total_amount) / NULLIF(COUNT(*), 0) AS avg_order_value
FROM orders
WHERE status = 'PAID'
GROUP BY CAST(order_date AS DATE);
```

Revenue per active user:

```sql
WITH daily_revenue AS (
  SELECT
    CAST(order_date AS DATE) AS metric_date,
    SUM(total_amount) AS revenue
  FROM orders
  WHERE status = 'PAID'
  GROUP BY CAST(order_date AS DATE)
),
daily_active AS (
  SELECT
    CAST(event_time AS DATE) AS metric_date,
    COUNT(DISTINCT user_id) AS active_users
  FROM events
  GROUP BY CAST(event_time AS DATE)
)
SELECT
  a.metric_date,
  r.revenue,
  a.active_users,
  1.0 * r.revenue / NULLIF(a.active_users, 0) AS revenue_per_active_user
FROM daily_active a
LEFT JOIN daily_revenue r
  ON r.metric_date = a.metric_date;
```

## 10. Rolling metrics

Rolling 7-day active users:

```sql
WITH daily_user_activity AS (
  SELECT DISTINCT
    CAST(event_time AS DATE) AS event_date,
    user_id
  FROM events
),
calendar AS (
  SELECT DISTINCT event_date
  FROM daily_user_activity
)
SELECT
  c.event_date,
  COUNT(DISTINCT a.user_id) AS rolling_7d_active_users
FROM calendar c
LEFT JOIN daily_user_activity a
  ON a.event_date >= c.event_date - INTERVAL '6' DAY
 AND a.event_date <= c.event_date
GROUP BY c.event_date
ORDER BY c.event_date;
```

Rolling metric có thể tốn tài nguyên. Với dữ liệu lớn, cân nhắc aggregate table.

## 11. Attribution cơ bản

Attribution gán conversion cho nguồn marketing.

Ví dụ last-touch attribution:

```sql
WITH touchpoints AS (
  SELECT
    user_id,
    campaign_id,
    event_time AS touch_time
  FROM events
  WHERE event_name = 'ad_click'
),
purchases AS (
  SELECT
    user_id,
    event_time AS purchase_time
  FROM events
  WHERE event_name = 'purchase'
),
ranked AS (
  SELECT
    p.user_id,
    p.purchase_time,
    t.campaign_id,
    ROW_NUMBER() OVER (
      PARTITION BY p.user_id, p.purchase_time
      ORDER BY t.touch_time DESC
    ) AS rn
  FROM purchases p
  JOIN touchpoints t
    ON t.user_id = p.user_id
   AND t.touch_time <= p.purchase_time
)
SELECT
  campaign_id,
  COUNT(*) AS attributed_purchases
FROM ranked
WHERE rn = 1
GROUP BY campaign_id;
```

Attribution cần định nghĩa rõ cửa sổ thời gian, ví dụ chỉ tính touchpoint trong 7 ngày trước purchase.

## 12. Lỗi analytical SQL phổ biến

- Metric không có định nghĩa rõ.
- Tính active user bằng event sai.
- Funnel không kiểm tra thứ tự event.
- Retention không xác định cohort đúng.
- Churn không thống nhất window inactive.
- Rolling metric thiếu ngày không có dữ liệu.
- Revenue không loại refund/cancelled.
- Join order và item làm nhân revenue.
- Không xử lý timezone.

## 13. Checklist analytical SQL

- Metric định nghĩa chính xác là gì?
- Grain kết quả là gì?
- Timezone nào được dùng?
- Có cần loại test/bot/internal users không?
- Có cần kiểm tra thứ tự event không?
- Có cần cửa sổ thời gian không?
- Có duplicate event không?
- Có late arriving data không?
- Có đối soát với source không?
- Query có chạy được trên dữ liệu lớn không?

## 14. Bài tập tự luyện

### Bài 1

Tính DAU theo ngày từ bảng `events`.

### Bài 2

Tính conversion rate từ `view_product` sang `purchase` theo user trong tháng 5/2026.

### Bài 3

Tính D1 retention theo ngày first seen.

### Bài 4

Tính AOV theo ngày từ bảng `orders`.

### Bài 5

Viết query last-touch attribution cho campaign trong vòng 7 ngày trước purchase.

## 15. Từ fresher lên senior ở analytical SQL

Fresher thường hỏi: "Query này ra số chưa?"

Senior hỏi:

- Số này định nghĩa thế nào?
- Có đúng grain không?
- Có đúng timezone không?
- Có tính nhầm duplicate không?
- Có thể giải thích cho business không?
- Có thể chạy ổn hàng ngày không?

Analytical SQL tốt bắt đầu từ metric definition tốt.

