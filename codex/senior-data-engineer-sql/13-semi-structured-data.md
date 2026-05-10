# Phần 13: Semi-Structured Data

Mục tiêu của phần này: giúp bạn làm việc với JSON, ARRAY, STRUCT, MAP và nested data bằng SQL. Đây là kỹ năng quan trọng trong hệ thống dữ liệu hiện đại vì event, API response, log và CDC thường chứa dữ liệu bán cấu trúc.

## 1. Semi-structured data là gì?

Semi-structured data là dữ liệu không hoàn toàn dạng bảng phẳng, nhưng vẫn có cấu trúc.

Ví dụ JSON:

```json
{
  "order_id": 1001,
  "customer_id": 1,
  "items": [
    {"product_id": 10, "quantity": 2},
    {"product_id": 11, "quantity": 1}
  ],
  "payment": {
    "method": "CARD",
    "status": "SUCCESS"
  }
}
```

Nguồn thường gặp:

- API response.
- Application events.
- Kafka messages.
- Logs.
- CDC payload.
- Web tracking events.

## 2. Vì sao Data Engineer cần biết?

Vì raw data hiện đại thường không sạch sẵn trong bảng quan hệ.

Data Engineer cần:

- Extract field từ JSON.
- Flatten array.
- Chuẩn hóa nested data thành fact/dimension.
- Kiểm tra schema drift.
- Xử lý missing field.
- Tối ưu query trên JSON/nested column.

## 3. JSON object và array

Object:

```json
{
  "customer_id": 1,
  "city": "Ha Noi"
}
```

Array:

```json
[
  {"product_id": 10, "quantity": 2},
  {"product_id": 11, "quantity": 1}
]
```

Nested object:

```json
{
  "payment": {
    "method": "CARD",
    "status": "SUCCESS"
  }
}
```

## 4. BigQuery UNNEST

Giả sử bảng `orders` có cột `items` là array of struct.

```sql
SELECT
  order_id,
  item.product_id,
  item.quantity
FROM orders,
UNNEST(items) AS item;
```

Nếu muốn giữ order không có items:

```sql
SELECT
  order_id,
  item.product_id,
  item.quantity
FROM orders
LEFT JOIN UNNEST(items) AS item;
```

Lưu ý: unnest array sẽ làm tăng số dòng.

## 5. Snowflake VARIANT và FLATTEN

Giả sử cột `payload` là VARIANT:

```sql
SELECT
  payload:order_id::NUMBER AS order_id,
  payload:payment.method::STRING AS payment_method
FROM raw_orders;
```

Flatten items:

```sql
SELECT
  payload:order_id::NUMBER AS order_id,
  item.value:product_id::NUMBER AS product_id,
  item.value:quantity::NUMBER AS quantity
FROM raw_orders,
LATERAL FLATTEN(input => payload:items) item;
```

## 6. Oracle JSON_TABLE

Giả sử bảng `raw_orders` có cột `payload` chứa JSON.

```sql
SELECT
  jt.order_id,
  jt.customer_id,
  jt.payment_method
FROM raw_orders r,
JSON_TABLE(
  r.payload,
  '$'
  COLUMNS (
    order_id       NUMBER       PATH '$.order_id',
    customer_id    NUMBER       PATH '$.customer_id',
    payment_method VARCHAR2(50) PATH '$.payment.method'
  )
) jt;
```

Flatten items:

```sql
SELECT
  jt.order_id,
  jt.product_id,
  jt.quantity
FROM raw_orders r,
JSON_TABLE(
  r.payload,
  '$'
  COLUMNS (
    order_id NUMBER PATH '$.order_id',
    NESTED PATH '$.items[*]'
    COLUMNS (
      product_id NUMBER PATH '$.product_id',
      quantity   NUMBER PATH '$.quantity'
    )
  )
) jt;
```

## 7. PostgreSQL JSONB

Extract field:

```sql
SELECT
  payload ->> 'order_id' AS order_id,
  payload -> 'payment' ->> 'method' AS payment_method
FROM raw_orders;
```

Flatten array:

```sql
SELECT
  payload ->> 'order_id' AS order_id,
  item ->> 'product_id' AS product_id,
  item ->> 'quantity' AS quantity
FROM raw_orders,
jsonb_array_elements(payload -> 'items') AS item;
```

## 8. Spark SQL explode

```sql
SELECT
  order_id,
  item.product_id,
  item.quantity
FROM orders
LATERAL VIEW explode(items) exploded AS item;
```

Hoặc với syntax mới tùy phiên bản Spark:

```sql
SELECT
  order_id,
  item.product_id,
  item.quantity
FROM orders
LATERAL VIEW explode(items) t AS item;
```

## 9. Flatten làm thay đổi grain

Trước flatten:

```text
Mỗi dòng là một order.
```

Sau flatten items:

```text
Mỗi dòng là một item trong order.
```

Ví dụ:

| order_id | items_count |
|----------|-------------|
| 1001     | 2           |

Sau flatten:

| order_id | product_id |
|----------|------------|
| 1001     | 10         |
| 1001     | 11         |

Nếu sau đó `SUM(order_total)`, doanh thu có thể bị nhân dòng.

Senior lesson: flatten array giống join 1-n. Phải kiểm soát grain.

## 10. Missing field và NULL

JSON có thể thiếu field.

Ví dụ:

```json
{"order_id": 1001}
```

Không có `payment.method`.

Khi extract, kết quả thường là `NULL`.

Cần phân biệt:

- Field không tồn tại.
- Field tồn tại nhưng value là null.
- Field sai kiểu dữ liệu.

Data quality check:

```sql
SELECT COUNT(*) AS missing_payment_method
FROM parsed_orders
WHERE payment_method IS NULL;
```

## 11. Schema drift trong JSON

JSON dễ thay đổi schema:

Version 1:

```json
{"customer_id": 1}
```

Version 2:

```json
{"customer": {"id": 1}}
```

Nếu pipeline chỉ đọc `$.customer_id`, version 2 sẽ ra null.

Cách xử lý:

- Versioning schema.
- Contract với source team.
- Data quality check cho field critical.
- Raw layer lưu payload gốc.
- Parser có fallback logic nếu cần.

## 12. Raw to structured model

Raw JSON:

```text
raw_orders(payload, ingested_at, batch_id)
```

Parsed order header:

```text
stg_orders(order_id, customer_id, payment_method, order_time)
```

Parsed items:

```text
stg_order_items(order_id, product_id, quantity, unit_price)
```

Model tốt thường không để toàn bộ analytics query trực tiếp trên raw JSON, vì:

- Khó đọc.
- Chậm hơn.
- Dễ lỗi schema drift.
- Khó test.

## 13. Data quality cho semi-structured data

Kiểm tra payload parse được không:

```sql
SELECT COUNT(*) AS invalid_records
FROM raw_orders
WHERE payload IS NULL;
```

Kiểm tra key bắt buộc:

```sql
SELECT COUNT(*) AS missing_order_id
FROM parsed_orders
WHERE order_id IS NULL;
```

Kiểm tra items rỗng:

```sql
SELECT COUNT(*) AS orders_without_items
FROM parsed_orders
WHERE item_count = 0;
```

## 14. Performance khi query JSON

Query trực tiếp JSON nhiều lần có thể chậm.

Tối ưu:

- Parse field hay dùng ra cột riêng.
- Dùng columnar format như Parquet.
- Partition theo field quan trọng như `event_date`.
- Tạo index/search optimization nếu database hỗ trợ.
- Tránh parse JSON trong dashboard query.

Không tốt:

```sql
SELECT
  JSON_VALUE(payload, '$.customer_id') AS customer_id,
  COUNT(*)
FROM raw_events
GROUP BY JSON_VALUE(payload, '$.customer_id');
```

Tốt hơn: parse trước vào bảng structured.

## 15. Minh họa thực tế: event tracking

Raw event:

```json
{
  "event_name": "purchase",
  "user_id": "u1",
  "event_time": "2026-05-08T10:00:00Z",
  "properties": {
    "order_id": "1001",
    "amount": 500000,
    "currency": "VND"
  }
}
```

Structured table:

```text
fact_events(
  event_id,
  user_id,
  event_name,
  event_time,
  event_date,
  order_id,
  amount,
  currency,
  raw_payload,
  ingested_at
)
```

Query analytics dùng structured columns:

```sql
SELECT
  event_date,
  SUM(amount) AS purchase_amount
FROM fact_events
WHERE event_name = 'purchase'
GROUP BY event_date;
```

## 16. Lỗi phổ biến

- Flatten array rồi quên grain đã thay đổi.
- Query dashboard trực tiếp trên raw JSON.
- Không lưu raw payload nên khó debug.
- Không kiểm tra missing field.
- Không xử lý schema drift.
- Cast sai kiểu dữ liệu.
- Không phân biệt event_time và ingestion_time.
- Parse timestamp nhưng mất timezone.

## 17. Checklist semi-structured data

- Payload gốc có được lưu không?
- Field critical đã parse ra cột riêng chưa?
- Array flatten có làm đổi grain không?
- Có schema drift check không?
- Có xử lý missing field không?
- Có cast kiểu dữ liệu rõ ràng không?
- Có partition theo date phù hợp không?
- Query analytics có tránh parse JSON lặp lại không?

## 18. Bài tập tự luyện

### Bài 1

Từ JSON order có mảng `items`, thiết kế 2 bảng structured: order header và order items.

### Bài 2

Viết Oracle `JSON_TABLE` để extract `order_id`, `customer_id`, `payment.method`.

### Bài 3

Giải thích vì sao flatten `items` có thể làm doanh thu bị nhân.

### Bài 4

Liệt kê các data quality checks cho raw event JSON.

### Bài 5

Thiết kế bảng `fact_events` từ raw event tracking.

## 19. Từ fresher lên senior ở semi-structured data

Fresher thường nghĩ: "JSON lấy được field là xong."

Senior nghĩ:

- Field này có ổn định không?
- Array flatten làm đổi grain thế nào?
- Query có bị chậm vì parse JSON lặp lại không?
- Có lưu raw để debug không?
- Schema drift sẽ được phát hiện ra sao?

Semi-structured data linh hoạt, nhưng nếu không quản lý tốt sẽ làm pipeline khó tin cậy.

