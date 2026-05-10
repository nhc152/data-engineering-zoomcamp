# Phần 8: Partitioning và dữ liệu lớn

Mục tiêu của phần này: giúp bạn hiểu cách tổ chức dữ liệu lớn để query nhanh, pipeline dễ vận hành và chi phí xử lý hợp lý. Với Data Engineer, partitioning là kỹ năng bắt buộc khi làm bảng lớn.

## 1. Vấn đề của dữ liệu lớn

Khi bảng tăng từ vài triệu lên vài tỷ dòng, các vấn đề xuất hiện:

- Query scan quá nhiều dữ liệu.
- Dashboard chậm.
- Batch ETL chạy quá lâu.
- Delete/update dữ liệu cũ rất tốn.
- Storage tăng nhanh.
- Index lớn và khó bảo trì.
- Backfill mất nhiều giờ hoặc nhiều ngày.

Giải pháp không chỉ là "thêm máy". Phải thiết kế bảng để database đọc ít dữ liệu hơn.

## 2. Partitioning là gì?

Partitioning là chia một bảng lớn thành nhiều phần nhỏ hơn theo một rule.

Ví dụ chia `fact_orders` theo tháng của `order_date`:

```text
fact_orders
  partition 2026-01
  partition 2026-02
  partition 2026-03
  partition 2026-04
  partition 2026-05
```

Khi query tháng 5, database chỉ cần đọc partition tháng 5.

Đó gọi là partition pruning.

## 3. Partition pruning

Partition pruning là việc database bỏ qua partition không liên quan.

Tốt:

```sql
SELECT
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-06-01';
```

Nếu bảng partition theo `order_date`, database chỉ đọc partition tháng 5.

Không tốt:

```sql
SELECT
  SUM(total_amount) AS revenue
FROM fact_orders
WHERE TO_CHAR(order_date, 'YYYY-MM') = '2026-05';
```

Function trên partition column có thể làm partition pruning kém hiệu quả.

## 4. Chọn partition key

Partition key nên là cột thường dùng để filter.

Các lựa chọn phổ biến:

- Ngày giao dịch: `order_date`, `event_date`.
- Ngày ingestion: `ingestion_date`.
- Region/country nếu dữ liệu phân vùng tự nhiên.
- Tenant/account nếu hệ thống multi-tenant.

Với Data Engineering, partition theo ngày/tháng là phổ biến nhất.

Không nên chọn partition key:

- Ít khi dùng trong `WHERE`.
- Có quá nhiều giá trị nhỏ gây nhiều partition.
- Có phân bố quá lệch.
- Hay thay đổi.

## 5. Partition theo event_date hay ingestion_date?

### event_date

Là ngày nghiệp vụ xảy ra.

Ví dụ:

```text
order_date
event_time
transaction_date
```

Phù hợp cho dashboard/reporting theo ngày nghiệp vụ.

### ingestion_date

Là ngày dữ liệu được load vào hệ thống.

Phù hợp cho vận hành pipeline, debug batch, replay ingestion.

Nhiều hệ thống dùng cả hai:

- Partition theo `event_date` cho query business.
- Có cột `ingestion_date` để debug và audit.

Nếu late arriving data nhiều, partition theo `event_date` cần hỗ trợ reprocess partition cũ.

## 6. Daily vs monthly partition

### Daily partition

Phù hợp khi:

- Dữ liệu mỗi ngày lớn.
- Query thường theo ngày hoặc vài ngày.
- Cần reprocess từng ngày.

Nhược điểm:

- Nhiều partition hơn.
- Cần quản lý metadata tốt.

### Monthly partition

Phù hợp khi:

- Dữ liệu mỗi ngày không quá lớn.
- Query thường theo tháng.
- Muốn ít partition hơn.

Nhược điểm:

- Query một ngày vẫn có thể phải scan partition cả tháng.

Senior lesson: partition size phải đủ lớn để hiệu quả nhưng không quá lớn khiến pruning kém.

## 7. Ví dụ Oracle range partition

```sql
CREATE TABLE fact_orders (
  order_id      NUMBER,
  customer_id   NUMBER,
  order_date    DATE,
  status        VARCHAR2(20),
  total_amount  NUMBER
)
PARTITION BY RANGE (order_date) (
  PARTITION p202605 VALUES LESS THAN (DATE '2026-06-01'),
  PARTITION p202606 VALUES LESS THAN (DATE '2026-07-01'),
  PARTITION pmax    VALUES LESS THAN (MAXVALUE)
);
```

Query tháng 5:

```sql
SELECT SUM(total_amount)
FROM fact_orders
WHERE order_date >= DATE '2026-05-01'
  AND order_date <  DATE '2026-06-01';
```

Oracle có thể chỉ đọc partition `p202605`.

## 8. Partition trong data lake

Trong data lake, partition thường là folder:

```text
s3://lake/fact_events/event_date=2026-05-08/
s3://lake/fact_events/event_date=2026-05-09/
```

Query:

```sql
SELECT COUNT(*)
FROM fact_events
WHERE event_date = DATE '2026-05-08';
```

Engine như Spark/Trino/Hive có thể chỉ đọc folder tương ứng.

Không tốt:

```sql
WHERE DATE(event_time) = DATE '2026-05-08'
```

nếu table partition theo `event_date` nhưng query không filter trực tiếp `event_date`.

## 9. Clustering, sort key, bucketing

Partition không giải quyết mọi thứ.

Nếu partition tháng 5 vẫn có 500 triệu dòng, query theo `customer_id` có thể vẫn chậm.

Các kỹ thuật bổ sung:

- Clustering: gom dữ liệu gần nhau theo một số cột.
- Sort key: sắp xếp vật lý theo cột.
- Bucketing: chia dữ liệu theo hash của key.
- Z-order: gom dữ liệu đa chiều trong một số lakehouse.

Ví dụ:

- Partition theo `event_date`.
- Cluster/Z-order theo `customer_id`.

Phù hợp khi query thường lọc:

```sql
WHERE event_date >= DATE '2026-05-01'
  AND customer_id = 1001
```

## 10. Small files problem

Trong data lake, quá nhiều file nhỏ làm query chậm vì overhead mở file lớn.

Ví dụ xấu:

```text
event_date=2026-05-08/
  part-00001.parquet 10 KB
  part-00002.parquet 12 KB
  ...
  part-50000.parquet 9 KB
```

Tác hại:

- Metadata nhiều.
- Scheduler overhead cao.
- Query chậm dù dữ liệu ít.

Cách xử lý:

- Compaction.
- Ghi file kích thước hợp lý.
- Tránh partition quá nhỏ.
- Batch write thay vì ghi từng record.

## 11. File format

Data Engineer cần hiểu file format:

### CSV

- Dễ đọc.
- Không có schema mạnh.
- Không columnar.
- Không nén tốt bằng parquet/orc cho analytics.

### Parquet

- Columnar.
- Tốt cho analytical query.
- Hỗ trợ compression.
- Hỗ trợ predicate pushdown/statistics.

### ORC

- Columnar.
- Phổ biến trong Hive ecosystem.

Với dữ liệu lớn phân tích, Parquet/ORC thường tốt hơn CSV.

## 12. Compression

Compression giảm storage và I/O.

Các codec phổ biến:

- Snappy: nhanh, nén vừa.
- Gzip: nén tốt hơn, CPU cao hơn.
- ZSTD: cân bằng tốt trong nhiều hệ thống hiện đại.

Trong analytical workloads, giảm I/O thường quan trọng hơn tăng CPU nhẹ.

## 13. Partition overwrite

Khi reprocess dữ liệu theo ngày, không nên rebuild toàn bảng.

Ý tưởng:

```sql
DELETE FROM fact_daily_revenue
WHERE revenue_date = DATE '2026-05-08';

INSERT INTO fact_daily_revenue
SELECT ...
WHERE revenue_date = DATE '2026-05-08';
```

Trong Spark/Delta/Hive có thể dùng dynamic partition overwrite tùy hệ thống.

Senior lesson: backfill nên tác động đúng partition cần sửa.

## 14. Retention và archive

Dữ liệu lớn cần chiến lược giữ/xóa:

- Giữ raw data 90 ngày?
- Giữ fact chi tiết 2 năm?
- Giữ aggregate 5 năm?
- Archive dữ liệu cũ sang storage rẻ hơn?

Partition giúp xóa/archive nhanh:

```sql
ALTER TABLE fact_orders DROP PARTITION p202401;
```

Nhanh hơn nhiều so với:

```sql
DELETE FROM fact_orders
WHERE order_date < DATE '2024-02-01';
```

Tùy database, drop partition có thể là metadata operation.

## 15. Hot partition

Hot partition là partition bị ghi/đọc quá nhiều.

Ví dụ tất cả event realtime ghi vào `event_date = current_date`.

Vấn đề:

- Contention.
- File nhỏ.
- Query đồng thời chậm.

Cách xử lý:

- Batch ghi theo micro-batch hợp lý.
- Sub-partition/bucket theo user_id hoặc hash.
- Compaction định kỳ.
- Tách realtime layer và batch layer.

## 16. Minh họa thực tế: bảng events 5 tỷ dòng

Yêu cầu:

- Dashboard xem event theo ngày.
- Analyst hay lọc theo `user_id`.
- Pipeline nhận dữ liệu trễ tối đa 3 ngày.

Thiết kế:

- Partition theo `event_date`.
- Lưu `ingestion_date`.
- Cluster/Z-order theo `user_id` nếu platform hỗ trợ.
- Reprocess 3 ngày gần nhất mỗi lần chạy.
- Compaction sau khi ghi.

Query tốt:

```sql
SELECT
  event_name,
  COUNT(*) AS event_count
FROM fact_events
WHERE event_date >= DATE '2026-05-01'
  AND event_date <  DATE '2026-05-08'
GROUP BY event_name;
```

Query không tốt:

```sql
SELECT
  event_name,
  COUNT(*) AS event_count
FROM fact_events
WHERE event_time >= TIMESTAMP '2026-05-01 00:00:00'
  AND event_time <  TIMESTAMP '2026-05-08 00:00:00'
GROUP BY event_name;
```

Nếu bảng partition theo `event_date`, nên filter trực tiếp `event_date`.

## 17. Lỗi partitioning phổ biến

- Partition theo cột ít dùng trong filter.
- Partition quá nhỏ gây quá nhiều partition/file.
- Partition quá lớn làm pruning kém.
- Query không filter partition column.
- Dùng function trên partition column.
- Không xử lý late arriving data.
- Không có compaction trong data lake.
- Không có retention policy.
- Nghĩ partition thay thế được index/clustering.

## 18. Checklist dữ liệu lớn

- Bảng có bao nhiêu dòng và tăng bao nhiêu mỗi ngày?
- Query chính filter theo cột nào?
- Partition key là gì?
- Partition size có hợp lý không?
- Query có filter trực tiếp partition column không?
- Có late arriving data không?
- Có cần reprocess N ngày gần nhất không?
- Có small files problem không?
- Có cần clustering/sort key/bucketing không?
- Có retention/archive strategy không?

## 19. Bài tập tự luyện

### Bài 1

Một bảng `fact_events` có 2 tỷ dòng, query chủ yếu theo ngày. Đề xuất partition key.

### Bài 2

Giải thích vì sao `WHERE DATE(event_time) = ...` có thể không tận dụng partition.

### Bài 3

So sánh daily partition và monthly partition.

### Bài 4

Giải thích small files problem trong data lake.

### Bài 5

Thiết kế chiến lược reprocess cho dữ liệu late tối đa 7 ngày.

## 20. Từ fresher lên senior ở phần dữ liệu lớn

Fresher thường nghĩ: "Bảng lớn thì query chậm."

Senior nghĩ:

- Query có đọc đúng partition không?
- File layout có hợp lý không?
- Dữ liệu có được cluster theo pattern truy vấn không?
- Backfill có chỉ chạm vào partition cần thiết không?
- Retention có rõ không?

Dữ liệu lớn không đáng sợ nếu bạn bắt database đọc đúng phần cần đọc.

