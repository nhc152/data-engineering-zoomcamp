# Phần 5: Data Modeling bằng SQL

Mục tiêu của phần này: giúp bạn hiểu cách thiết kế bảng dữ liệu phục vụ phân tích và pipeline. Senior Data Engineer không chỉ viết query, mà còn thiết kế mô hình dữ liệu để query đúng, nhanh, dễ mở rộng và dễ tin cậy.

## 1. Data modeling là gì?

Data modeling là cách tổ chức dữ liệu thành bảng, cột, khóa và quan hệ để phục vụ mục tiêu sử dụng.

Trong Data Engineering, data modeling trả lời các câu hỏi:

- Bảng này đại diện cho thực thể hay sự kiện gì?
- Mỗi dòng trong bảng là gì?
- Khóa chính là gì?
- Bảng này liên kết với bảng nào?
- Dữ liệu có cần lưu lịch sử không?
- Query phân tích chính là gì?
- Dữ liệu sẽ tăng như thế nào?

Một model tốt giúp:

- Dễ hiểu dữ liệu.
- Giảm sai sót khi join.
- Tăng hiệu năng query.
- Dễ kiểm tra chất lượng.
- Dễ mở rộng khi nghiệp vụ thay đổi.

## 2. OLTP và OLAP

### OLTP

OLTP là hệ thống giao dịch, ví dụ app bán hàng, ngân hàng, CRM.

Đặc điểm:

- Ghi dữ liệu thường xuyên.
- Giao dịch nhỏ.
- Cần tính nhất quán cao.
- Thiết kế thường chuẩn hóa.

Ví dụ bảng OLTP:

- `users`
- `orders`
- `order_items`
- `payments`

### OLAP

OLAP là hệ thống phân tích, ví dụ data warehouse, BI dashboard.

Đặc điểm:

- Đọc nhiều.
- Query tổng hợp lớn.
- Dữ liệu lịch sử.
- Thiết kế thường denormalized hơn.

Ví dụ bảng OLAP:

- `fact_orders`
- `fact_order_items`
- `dim_customer`
- `dim_product`
- `dim_date`

Senior Data Engineer cần biết chuyển dữ liệu từ OLTP sang OLAP theo mô hình phù hợp.

## 3. Normalization

Normalization là tách dữ liệu thành nhiều bảng để giảm trùng lặp và tăng tính nhất quán.

Ví dụ không chuẩn hóa:

| order_id | customer_id | customer_name | customer_email | product_id | product_name |
|----------|-------------|---------------|----------------|------------|--------------|
| 1001     | 1           | An            | an@example.com  | 10         | Keyboard     |
| 1002     | 1           | An            | an@example.com  | 11         | Mouse        |

Thông tin customer bị lặp.

Chuẩn hóa:

`customers`:

| customer_id | customer_name | customer_email |
|-------------|---------------|----------------|
| 1           | An            | an@example.com  |

`orders`:

| order_id | customer_id |
|----------|-------------|
| 1001     | 1           |
| 1002     | 1           |

Lợi ích:

- Giảm trùng dữ liệu.
- Cập nhật customer một nơi.
- Phù hợp OLTP.

Nhược điểm:

- Query phân tích cần nhiều join.
- Có thể chậm hơn với báo cáo lớn.

## 4. Denormalization

Denormalization là chủ động lưu trùng một phần dữ liệu để query dễ hơn và nhanh hơn.

Ví dụ bảng `fact_orders` có thêm `customer_city`:

| order_id | customer_id | customer_city | order_date | total_amount |
|----------|-------------|---------------|------------|--------------|
| 1001     | 1           | Ha Noi        | 2026-05-01 | 500000       |

Lợi ích:

- Giảm join khi báo cáo.
- Query nhanh hơn.
- Dễ dùng cho BI.

Nhược điểm:

- Dữ liệu có thể không đồng bộ nếu không quản lý tốt.
- Cần định nghĩa rõ giá trị tại thời điểm nào.

Câu hỏi quan trọng: `customer_city` là city hiện tại hay city tại thời điểm order?

## 5. Star schema

Star schema là mô hình phổ biến trong data warehouse.

Gồm:

- Fact table ở giữa.
- Dimension tables xung quanh.

Ví dụ:

```text
dim_customer     dim_product
      \             /
       \           /
        fact_order_items
       /           \
dim_date        dim_store
```

Fact table lưu sự kiện/số đo.

Dimension table lưu mô tả/ngữ cảnh.

## 6. Fact table

Fact table lưu các sự kiện hoặc số đo.

Ví dụ `fact_order_items`:

| order_id | product_id | customer_id | order_date_key | quantity | gross_amount |
|----------|------------|-------------|----------------|----------|--------------|
| 1001     | 10         | 1           | 20260501       | 2        | 200000       |
| 1001     | 11         | 1           | 20260501       | 1        | 300000       |

Fact thường có:

- Foreign keys tới dimensions.
- Measures như `quantity`, `amount`, `duration`.
- Event timestamp hoặc date key.

Điều quan trọng nhất: grain.

Ví dụ grain:

```text
Mỗi dòng trong fact_order_items là một product item trong một order.
```

Nếu grain không rõ, metric sẽ rất dễ sai.

## 7. Dimension table

Dimension table mô tả đối tượng.

Ví dụ `dim_customer`:

| customer_key | customer_id | full_name | city | valid_from | valid_to | is_current |
|--------------|-------------|-----------|------|------------|----------|------------|
| 101          | 1           | An        | Ha Noi | 2026-01-01 | 9999-12-31 | Y |

Dimension thường chứa:

- Customer.
- Product.
- Store.
- Date.
- Campaign.
- Region.

Dimension giúp phân tích fact theo nhiều chiều:

- Doanh thu theo city.
- Doanh thu theo product category.
- Số order theo campaign.

## 8. Grain: câu hỏi sống còn

Trước khi tạo bảng, luôn viết grain ra bằng một câu.

Ví dụ tốt:

```text
fact_orders: mỗi dòng là một order.
fact_order_items: mỗi dòng là một product trong một order.
fact_daily_customer_revenue: mỗi dòng là doanh thu của một customer trong một ngày.
```

Ví dụ mơ hồ:

```text
Bảng này lưu thông tin order và customer.
```

Mơ hồ vì không biết mỗi dòng là order, customer, hay order item.

Nếu grain rõ:

- Join dễ đúng.
- Aggregate dễ đúng.
- Data quality check dễ viết.
- Người khác dễ dùng.

## 9. Primary key, foreign key, natural key, surrogate key

### Primary key

Khóa chính định danh duy nhất một dòng.

```sql
CREATE TABLE dim_customer (
  customer_key NUMBER PRIMARY KEY,
  customer_id  NUMBER NOT NULL,
  full_name    VARCHAR2(255)
);
```

### Foreign key

Khóa ngoại liên kết sang bảng khác.

```sql
CREATE TABLE fact_orders (
  order_id      NUMBER PRIMARY KEY,
  customer_key  NUMBER,
  total_amount  NUMBER,
  CONSTRAINT fk_fact_orders_customer
    FOREIGN KEY (customer_key)
    REFERENCES dim_customer(customer_key)
);
```

Trong data warehouse, không phải lúc nào cũng enforce foreign key vật lý, nhưng logic quan hệ vẫn phải rõ.

### Natural key

Key đến từ hệ thống nghiệp vụ.

Ví dụ:

- `customer_id` từ app.
- `product_code` từ ERP.

### Surrogate key

Key do data warehouse tự sinh.

Ví dụ:

- `customer_key`
- `product_key`

Surrogate key hữu ích khi cần lưu lịch sử dimension.

## 10. Slowly Changing Dimension Type 1

SCD Type 1 ghi đè dữ liệu cũ, không giữ lịch sử.

Ví dụ customer đổi city từ `Ha Noi` sang `Da Nang`.

Trước:

| customer_id | full_name | city |
|-------------|-----------|------|
| 1           | An        | Ha Noi |

Sau:

| customer_id | full_name | city |
|-------------|-----------|------|
| 1           | An        | Da Nang |

SQL merge mẫu:

```sql
MERGE INTO dim_customer t
USING stg_customer s
ON (t.customer_id = s.customer_id)
WHEN MATCHED THEN
  UPDATE SET
    t.full_name = s.full_name,
    t.city = s.city,
    t.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (customer_id, full_name, city, created_at, updated_at)
  VALUES (s.customer_id, s.full_name, s.city, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

Phù hợp khi:

- Không cần lịch sử.
- Chỉ quan tâm trạng thái mới nhất.

## 11. Slowly Changing Dimension Type 2

SCD Type 2 giữ lịch sử thay đổi bằng nhiều dòng.

Ví dụ customer đổi city.

| customer_key | customer_id | city   | valid_from | valid_to   | is_current |
|--------------|-------------|--------|------------|------------|------------|
| 101          | 1           | Ha Noi | 2026-01-01 | 2026-05-07 | N          |
| 205          | 1           | Da Nang | 2026-05-08 | 9999-12-31 | Y          |

Khi order xảy ra ngày 2026-04-01, join vào record `Ha Noi`.

Khi order xảy ra ngày 2026-06-01, join vào record `Da Nang`.

Join fact với SCD2:

```sql
SELECT
  f.order_id,
  f.order_date,
  d.customer_key,
  d.city
FROM fact_orders f
JOIN dim_customer d
  ON d.customer_id = f.customer_id
 AND f.order_date >= d.valid_from
 AND f.order_date <  d.valid_to;
```

Lưu ý:

- Nên dùng khoảng thời gian nửa mở: `>= valid_from` và `< valid_to`.
- Cần đảm bảo không có interval overlap cho cùng natural key.

## 12. Snapshot table

Snapshot table lưu trạng thái tại một thời điểm.

Ví dụ `fact_account_daily_snapshot`:

| snapshot_date | account_id | balance |
|---------------|------------|---------|
| 2026-05-01    | A1         | 1000000 |
| 2026-05-02    | A1         | 1200000 |

Grain:

```text
Mỗi dòng là trạng thái một account tại một ngày.
```

Phù hợp cho:

- Balance tài khoản.
- Inventory cuối ngày.
- User subscription status.
- Customer lifecycle stage.

Không nên tính balance cuối ngày từ transaction mỗi lần nếu dữ liệu rất lớn và báo cáo chạy thường xuyên.

## 13. Accumulating snapshot

Accumulating snapshot dùng cho process có nhiều mốc thời gian.

Ví dụ order lifecycle:

| order_id | created_at | paid_at | shipped_at | delivered_at | cancelled_at |
|----------|------------|---------|------------|--------------|--------------|
| 1001     | 10:00      | 10:05   | 12:00      | 18:00        | NULL         |

Phù hợp để phân tích:

- Thời gian từ tạo đơn đến thanh toán.
- Thời gian từ thanh toán đến giao hàng.
- Tỷ lệ hủy theo từng bước.

## 14. Bridge table

Bridge table xử lý quan hệ nhiều-nhiều.

Ví dụ một order có nhiều promotion, một promotion áp dụng cho nhiều order.

```text
fact_orders
order_promotion_bridge
dim_promotion
```

Bridge table:

| order_id | promotion_id |
|----------|--------------|
| 1001     | P10          |
| 1001     | P20          |

Khi aggregate, phải cẩn thận để không nhân revenue nếu một order có nhiều promotion.

## 15. Date dimension

`dim_date` giúp phân tích theo calendar.

Ví dụ:

| date_key | full_date  | year | month | day | week_of_year | is_weekend |
|----------|------------|------|-------|-----|--------------|------------|
| 20260508 | 2026-05-08 | 2026 | 5     | 8   | 19           | N          |

Lợi ích:

- Dễ group theo tuần, tháng, quý.
- Dễ xử lý holiday, weekend.
- Dễ join với fact.

Ví dụ:

```sql
SELECT
  d.year,
  d.month,
  SUM(f.total_amount) AS revenue
FROM fact_orders f
JOIN dim_date d
  ON d.date_key = f.order_date_key
GROUP BY d.year, d.month;
```

## 16. Naming convention

Tên bảng nên thể hiện loại bảng và grain.

Ví dụ:

- `stg_orders`
- `dim_customer`
- `dim_product`
- `fact_orders`
- `fact_order_items`
- `fact_daily_customer_revenue`
- `agg_monthly_product_sales`

Tên cột nên rõ:

- `created_at`
- `updated_at`
- `order_date`
- `order_timestamp`
- `customer_id`
- `customer_key`
- `is_current`
- `valid_from`
- `valid_to`

Không nên đặt tên mơ hồ:

- `date`
- `type`
- `value`
- `flag`
- `name`

nếu không có ngữ cảnh rõ.

## 17. Audit columns

Pipeline production nên có audit columns.

Ví dụ:

```sql
CREATE TABLE fact_orders (
  order_id        NUMBER,
  customer_id     NUMBER,
  order_date      TIMESTAMP,
  total_amount    NUMBER,
  source_system   VARCHAR2(50),
  batch_id        VARCHAR2(100),
  inserted_at     TIMESTAMP,
  updated_at      TIMESTAMP
);
```

Audit columns giúp:

- Biết dữ liệu đến từ đâu.
- Debug batch lỗi.
- Đối soát dữ liệu.
- Theo dõi freshness.

## 18. Data quality theo model

Mỗi model nên có test.

Ví dụ test primary key:

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Test foreign key:

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

Test amount không âm:

```sql
SELECT *
FROM fact_orders
WHERE total_amount < 0;
```

Test SCD2 overlap:

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

## 19. Minh họa thực tế: thiết kế model bán hàng

Yêu cầu:

Business muốn dashboard:

- Doanh thu theo ngày.
- Doanh thu theo city.
- Doanh thu theo product category.
- Số order theo status.
- Top product theo revenue.

Model đề xuất:

### dim_customer

Grain:

```text
Mỗi dòng là một phiên bản customer.
```

Cột:

- `customer_key`
- `customer_id`
- `full_name`
- `city`
- `valid_from`
- `valid_to`
- `is_current`

### dim_product

Grain:

```text
Mỗi dòng là một product.
```

Cột:

- `product_key`
- `product_id`
- `product_name`
- `category`

### dim_date

Grain:

```text
Mỗi dòng là một ngày.
```

### fact_order_items

Grain:

```text
Mỗi dòng là một product item trong một order.
```

Cột:

- `order_id`
- `order_item_id`
- `customer_key`
- `product_key`
- `order_date_key`
- `status`
- `quantity`
- `unit_price`
- `gross_amount`

Query doanh thu theo city:

```sql
SELECT
  c.city,
  SUM(f.gross_amount) AS revenue
FROM fact_order_items f
JOIN dim_customer c
  ON c.customer_key = f.customer_key
WHERE f.status = 'PAID'
GROUP BY c.city;
```

Query doanh thu theo category:

```sql
SELECT
  p.category,
  SUM(f.gross_amount) AS revenue
FROM fact_order_items f
JOIN dim_product p
  ON p.product_key = f.product_key
WHERE f.status = 'PAID'
GROUP BY p.category;
```

## 20. Lỗi data modeling phổ biến

- Không định nghĩa grain.
- Trộn nhiều grain trong một bảng.
- Không phân biệt natural key và surrogate key.
- Không biết dimension có cần SCD hay không.
- Dùng fact table như dimension.
- Lưu metric đã aggregate nhưng không ghi rõ grain.
- Thiếu audit columns.
- Thiếu data quality tests.
- Tạo bảng quá normalized cho BI, làm dashboard join phức tạp.
- Tạo bảng quá denormalized nhưng không kiểm soát đồng bộ.

## 21. Checklist thiết kế bảng

Trước khi tạo bảng mới, trả lời:

- Bảng này phục vụ use case nào?
- Mỗi dòng đại diện cho gì?
- Primary key là gì?
- Có foreign key logic nào?
- Có cần lưu lịch sử không?
- Có cần SCD Type 1 hay Type 2 không?
- Dữ liệu tăng theo ngày bao nhiêu?
- Query chính sẽ filter theo cột nào?
- Query chính sẽ group theo cột nào?
- Có cần partition không?
- Có cần audit columns không?
- Data quality tests là gì?

## 22. Bài tập tự luyện

### Bài 1

Định nghĩa grain cho các bảng:

- `fact_orders`
- `fact_order_items`
- `fact_daily_customer_revenue`
- `dim_customer`

### Bài 2

Thiết kế bảng `dim_product` cho hệ thống bán hàng.

### Bài 3

Thiết kế bảng `fact_order_items`, liệt kê key, measures và audit columns.

### Bài 4

Viết SQL kiểm tra duplicate primary key trong `fact_order_items`.

### Bài 5

Giải thích khi nào nên dùng SCD Type 1 và khi nào nên dùng SCD Type 2 cho `dim_customer`.

## 23. Từ fresher lên senior ở phần data modeling

Fresher thường nghĩ: "Có dữ liệu nào thì tạo bảng đó."

Senior nghĩ:

- Bảng này giải quyết bài toán gì?
- Grain là gì?
- Người dùng sẽ join bảng này như thế nào?
- Metric có bị tính sai không?
- Dữ liệu lịch sử có cần giữ không?
- Model này có chịu được khi dữ liệu tăng không?
- Làm sao kiểm tra bảng này đúng?

Data modeling tốt giúp SQL đơn giản hơn. Data modeling kém khiến mọi query phía sau đều phức tạp và dễ sai.

