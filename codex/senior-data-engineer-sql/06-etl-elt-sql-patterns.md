# Phần 6: SQL cho ETL/ELT

Mục tiêu của phần này: giúp bạn dùng SQL để xây pipeline dữ liệu đúng, chạy lại an toàn, dễ debug và phù hợp với production. Đây là kỹ năng cốt lõi của Data Engineer.

## 1. ETL và ELT là gì?

### ETL

ETL là:

```text
Extract -> Transform -> Load
```

Nghĩa là:

1. Lấy dữ liệu từ source.
2. Biến đổi dữ liệu bên ngoài database/data warehouse.
3. Load dữ liệu đã xử lý vào target.

### ELT

ELT là:

```text
Extract -> Load -> Transform
```

Nghĩa là:

1. Lấy dữ liệu từ source.
2. Load dữ liệu thô vào staging/raw layer.
3. Dùng SQL trong warehouse để transform.

Trong data warehouse hiện đại, ELT rất phổ biến vì Snowflake, BigQuery, Databricks, Redshift, Oracle, PostgreSQL đều có khả năng xử lý SQL mạnh.

## 2. Các layer dữ liệu phổ biến

Một pipeline thường chia thành nhiều layer:

```text
source -> raw/staging -> intermediate -> mart -> dashboard
```

### Raw/Staging

Lưu dữ liệu gần giống source nhất.

Ví dụ:

```text
stg_orders
stg_customers
stg_payments
```

Đặc điểm:

- Ít transform.
- Có audit columns như `ingested_at`, `batch_id`.
- Dùng để debug và backfill.

### Intermediate

Làm sạch, chuẩn hóa, dedup.

Ví dụ:

```text
int_orders_deduped
int_customer_latest
```

### Mart

Phục vụ business/reporting.

Ví dụ:

```text
fact_orders
dim_customer
agg_daily_revenue
```

Senior lesson: không nên nhồi toàn bộ logic vào một query khổng lồ. Chia layer giúp dễ kiểm tra và bảo trì.

## 3. Full refresh

Full refresh là xóa và build lại toàn bộ target từ source.

Ví dụ:

```sql
CREATE OR REPLACE TABLE dim_product AS
SELECT
  product_id,
  product_name,
  category,
  brand,
  CURRENT_TIMESTAMP AS updated_at
FROM stg_product;
```

Phù hợp khi:

- Bảng nhỏ.
- Logic đơn giản.
- Source có đầy đủ dữ liệu lịch sử.
- Chấp nhận rebuild toàn bộ.

Không phù hợp khi:

- Bảng rất lớn.
- Source chỉ có dữ liệu incremental.
- Rebuild tốn nhiều thời gian/tài nguyên.

## 4. Incremental load

Incremental load chỉ xử lý phần dữ liệu mới hoặc thay đổi.

Ví dụ lấy order mới theo `updated_at`:

```sql
SELECT
  order_id,
  customer_id,
  status,
  total_amount,
  created_at,
  updated_at
FROM stg_orders
WHERE updated_at > (
  SELECT COALESCE(MAX(updated_at), TIMESTAMP '1900-01-01 00:00:00')
  FROM fact_orders
);
```

Rủi ro:

- Nếu source update bản ghi cũ với `updated_at` không đúng, sẽ miss data.
- Nếu pipeline fail giữa chừng, watermark có thể sai.
- Late arriving data có thể bị bỏ qua.

Senior thường dùng overlap window:

```sql
WHERE updated_at >= (
  SELECT COALESCE(MAX(updated_at), TIMESTAMP '1900-01-01 00:00:00') - INTERVAL '1' DAY
  FROM fact_orders
)
```

Sau đó dedup/upsert lại target.

## 5. Watermark

Watermark là mốc đánh dấu dữ liệu đã xử lý đến đâu.

Ví dụ bảng quản lý pipeline:

```text
etl_watermark
```

| pipeline_name | last_success_time     |
|---------------|-----------------------|
| load_orders   | 2026-05-08 10:00:00   |

Query incremental:

```sql
SELECT *
FROM stg_orders
WHERE updated_at > (
  SELECT last_success_time
  FROM etl_watermark
  WHERE pipeline_name = 'load_orders'
);
```

Chỉ update watermark sau khi target load thành công.

## 6. Idempotency

Idempotent nghĩa là chạy lại nhiều lần vẫn cho cùng một kết quả đúng.

Pipeline không idempotent:

```sql
INSERT INTO fact_orders
SELECT *
FROM stg_orders
WHERE order_date = DATE '2026-05-08';
```

Nếu chạy lại, dữ liệu bị duplicate.

Cách tốt hơn: delete partition rồi insert lại.

```sql
DELETE FROM fact_orders
WHERE order_date = DATE '2026-05-08';

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
FROM stg_orders
WHERE order_date = DATE '2026-05-08';
```

Hoặc dùng `MERGE`.

Senior lesson: pipeline production phải chạy lại được sau khi fail.

## 7. INSERT SELECT

Mẫu load đơn giản:

```sql
INSERT INTO fact_orders (
  order_id,
  customer_id,
  order_date,
  status,
  total_amount,
  batch_id,
  inserted_at
)
SELECT
  order_id,
  customer_id,
  order_date,
  status,
  total_amount,
  :batch_id AS batch_id,
  CURRENT_TIMESTAMP AS inserted_at
FROM stg_orders
WHERE ingestion_date = DATE '2026-05-08';
```

Luôn ghi rõ danh sách cột trong `INSERT`.

Không nên:

```sql
INSERT INTO fact_orders
SELECT *
FROM stg_orders;
```

Vì nếu thứ tự cột thay đổi hoặc source thêm cột, pipeline có thể lỗi hoặc ghi sai dữ liệu.

## 8. MERGE/UPSERT

`MERGE` dùng để insert record mới và update record đã tồn tại.

Ví dụ:

```sql
MERGE INTO fact_orders t
USING stg_orders s
ON (t.order_id = s.order_id)
WHEN MATCHED THEN
  UPDATE SET
    t.customer_id = s.customer_id,
    t.status = s.status,
    t.total_amount = s.total_amount,
    t.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (
    order_id,
    customer_id,
    status,
    total_amount,
    inserted_at,
    updated_at
  )
  VALUES (
    s.order_id,
    s.customer_id,
    s.status,
    s.total_amount,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  );
```

Trước khi `MERGE`, cần đảm bảo source không duplicate key.

Kiểm tra:

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Nếu source duplicate, `MERGE` có thể lỗi hoặc kết quả không xác định tùy database.

## 9. Dedup trong staging

Lấy bản ghi mới nhất mỗi `order_id`:

```sql
WITH ranked AS (
  SELECT
    order_id,
    customer_id,
    status,
    total_amount,
    updated_at,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY updated_at DESC, ingestion_id DESC
    ) AS rn
  FROM stg_orders
)
SELECT
  order_id,
  customer_id,
  status,
  total_amount,
  updated_at
FROM ranked
WHERE rn = 1;
```

Luôn có tie-breaker nếu timestamp có thể trùng.

## 10. CDC: Change Data Capture

CDC ghi nhận thay đổi từ source:

- `INSERT`
- `UPDATE`
- `DELETE`

Ví dụ staging CDC:

| order_id | status | operation | event_time |
|----------|--------|-----------|------------|
| 1001     | PAID   | INSERT    | 10:00      |
| 1001     | CANCELLED | UPDATE | 10:10      |
| 1002     | NULL   | DELETE    | 10:20      |

Lấy event mới nhất:

```sql
WITH latest AS (
  SELECT
    order_id,
    status,
    operation,
    event_time,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY event_time DESC
    ) AS rn
  FROM stg_orders_cdc
)
SELECT *
FROM latest
WHERE rn = 1;
```

Áp dụng delete logic:

```sql
MERGE INTO fact_orders t
USING latest_orders s
ON (t.order_id = s.order_id)
WHEN MATCHED AND s.operation = 'DELETE' THEN
  DELETE
WHEN MATCHED THEN
  UPDATE SET
    t.status = s.status,
    t.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED AND s.operation <> 'DELETE' THEN
  INSERT (order_id, status, inserted_at, updated_at)
  VALUES (s.order_id, s.status, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

Cú pháp `MERGE DELETE` khác nhau tùy database, cần kiểm tra dialect.

## 11. Late arriving data

Late arriving data là dữ liệu đến muộn.

Ví dụ:

- Hôm nay là 2026-05-08.
- Pipeline nhận thêm order của ngày 2026-05-05.

Nếu chỉ load:

```sql
WHERE order_date = CURRENT_DATE
```

sẽ bỏ sót dữ liệu đến muộn.

Cách xử lý:

- Load theo `updated_at` thay vì `order_date`.
- Dùng overlap window.
- Reprocess N ngày gần nhất.
- Có job backfill.

Ví dụ reprocess 7 ngày gần nhất:

```sql
DELETE FROM fact_daily_revenue
WHERE revenue_date >= CURRENT_DATE - INTERVAL '7' DAY;

INSERT INTO fact_daily_revenue (
  revenue_date,
  revenue
)
SELECT
  CAST(order_date AS DATE) AS revenue_date,
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE status = 'PAID'
  AND order_date >= CURRENT_DATE - INTERVAL '7' DAY
GROUP BY CAST(order_date AS DATE);
```

## 12. Backfill

Backfill là chạy lại dữ liệu lịch sử.

Ví dụ backfill doanh thu tháng 4/2026:

```sql
DELETE FROM fact_daily_revenue
WHERE revenue_date >= DATE '2026-04-01'
  AND revenue_date <  DATE '2026-05-01';

INSERT INTO fact_daily_revenue (
  revenue_date,
  revenue
)
SELECT
  CAST(order_date AS DATE) AS revenue_date,
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE status = 'PAID'
  AND order_date >= DATE '2026-04-01'
  AND order_date <  DATE '2026-05-01'
GROUP BY CAST(order_date AS DATE);
```

Backfill tốt cần:

- Có date range rõ.
- Có log batch.
- Có thể chạy lại.
- Không ảnh hưởng dữ liệu ngoài phạm vi.
- Có kiểm tra trước/sau.

## 13. Audit columns

Các cột nên có:

- `source_system`
- `batch_id`
- `ingested_at`
- `inserted_at`
- `updated_at`
- `record_hash`

Ví dụ:

```sql
SELECT
  order_id,
  customer_id,
  status,
  total_amount,
  'ecommerce_app' AS source_system,
  :batch_id AS batch_id,
  CURRENT_TIMESTAMP AS inserted_at
FROM stg_orders;
```

Audit columns giúp debug:

- Record này đến từ batch nào?
- Khi nào record được load?
- Source nào gửi record này?
- Vì sao hôm nay số dòng tăng?

## 14. Record hash

Record hash giúp phát hiện dữ liệu thay đổi.

Ví dụ ý tưởng:

```sql
MD5(
  COALESCE(CAST(customer_id AS VARCHAR), '') || '|' ||
  COALESCE(status, '') || '|' ||
  COALESCE(CAST(total_amount AS VARCHAR), '')
) AS record_hash
```

Khi hash khác, record đã thay đổi.

Lưu ý:

- Cần chuẩn hóa format trước khi hash.
- Cẩn thận với `NULL`.
- Cẩn thận với kiểu số và timestamp.

## 15. Minh họa thực tế: load fact_orders incremental

Yêu cầu:

- Source là `stg_orders`.
- Target là `fact_orders`.
- Load dữ liệu thay đổi trong 2 ngày gần nhất.
- Dedup theo `order_id`, lấy `updated_at` mới nhất.
- Upsert vào target.

SQL mẫu:

```sql
WITH incremental_source AS (
  SELECT *
  FROM stg_orders
  WHERE updated_at >= CURRENT_TIMESTAMP - INTERVAL '2' DAY
),
deduped AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    updated_at,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY updated_at DESC, ingestion_id DESC
    ) AS rn
  FROM incremental_source
),
final_source AS (
  SELECT
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    updated_at
  FROM deduped
  WHERE rn = 1
)
MERGE INTO fact_orders t
USING final_source s
ON (t.order_id = s.order_id)
WHEN MATCHED THEN
  UPDATE SET
    t.customer_id = s.customer_id,
    t.order_date = s.order_date,
    t.status = s.status,
    t.total_amount = s.total_amount,
    t.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (
    order_id,
    customer_id,
    order_date,
    status,
    total_amount,
    inserted_at,
    updated_at
  )
  VALUES (
    s.order_id,
    s.customer_id,
    s.order_date,
    s.status,
    s.total_amount,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
  );
```

## 16. Data validation sau load

Sau pipeline, nên kiểm tra:

```sql
SELECT COUNT(*) AS source_count
FROM stg_orders
WHERE updated_at >= CURRENT_TIMESTAMP - INTERVAL '2' DAY;
```

```sql
SELECT COUNT(*) AS target_count
FROM fact_orders
WHERE updated_at >= CURRENT_TIMESTAMP - INTERVAL '2' DAY;
```

Kiểm tra duplicate:

```sql
SELECT
  order_id,
  COUNT(*) AS cnt
FROM fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Kiểm tra amount bất thường:

```sql
SELECT *
FROM fact_orders
WHERE total_amount < 0;
```

## 17. Lỗi ETL/ELT phổ biến

- Pipeline không idempotent.
- Dùng `INSERT SELECT *`.
- Không dedup source trước khi merge.
- Update watermark trước khi load thành công.
- Không xử lý late arriving data.
- Không có audit columns.
- Không có kiểm tra duplicate.
- Không có backfill strategy.
- Logic transform quá dài trong một query.
- Không ghi rõ grain của target table.

## 18. Checklist ETL/ELT SQL

- Pipeline chạy lại có bị duplicate không?
- Source có duplicate key không?
- Có xử lý late arriving data không?
- Có audit columns không?
- Có ghi rõ danh sách cột khi insert không?
- Có kiểm tra row count trước/sau không?
- Có validate null/duplicate/range không?
- Có update watermark đúng thời điểm không?
- Có thể backfill theo date range không?
- Query có đủ rõ để review không?

## 19. Bài tập tự luyện

### Bài 1

Viết SQL incremental load `fact_orders` từ `stg_orders` bằng `updated_at`.

### Bài 2

Viết SQL dedup `stg_customers` theo `customer_id`, lấy record mới nhất.

### Bài 3

Viết SQL kiểm tra duplicate `order_id` trong target sau khi load.

### Bài 4

Thiết kế bảng watermark đơn giản cho pipeline `load_orders`.

### Bài 5

Giải thích vì sao pipeline chỉ dùng `INSERT INTO target SELECT ...` có thể nguy hiểm khi retry.

## 20. Từ fresher lên senior ở phần ETL/ELT

Fresher thường nghĩ: "Load được dữ liệu vào bảng là xong."

Senior nghĩ:

- Chạy lại có an toàn không?
- Fail giữa chừng thì sao?
- Dữ liệu đến muộn thì sao?
- Source duplicate thì sao?
- Có kiểm tra kết quả sau load không?
- Có backfill được không?
- Có đủ log để debug không?

ETL/ELT production không chỉ là SQL đúng, mà là SQL có khả năng sống sót trong vận hành thực tế.

