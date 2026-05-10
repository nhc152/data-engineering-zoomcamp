# Phần 17: Lộ trình học SQL cho Senior Data Engineer

Mục tiêu của phần này: đưa ra lộ trình học từ fresher đến senior, theo đúng thứ tự kỹ năng cần xây dựng. SQL cho Data Engineer không chỉ là cú pháp, mà là tư duy dữ liệu, mô hình, hiệu năng và vận hành production.

## 1. Bức tranh tổng quan

Lộ trình nên đi theo 7 tầng:

```text
1. SQL fundamentals
2. Correctness: join, aggregation, null, time
3. Analytical SQL: window, metrics, cohort
4. Data modeling: fact, dimension, grain
5. ETL/ELT production patterns
6. Performance and scale
7. Governance, quality, debugging
```

Không nên nhảy ngay vào tuning hoặc window function nếu join và aggregation chưa chắc.

## 2. Giai đoạn 1: SQL căn bản

Mục tiêu:

- Viết được query đọc dữ liệu.
- Hiểu `WHERE`, `GROUP BY`, `ORDER BY`.
- Biết xử lý `NULL`.
- Biết dùng `CASE WHEN`.

Cần học:

- `SELECT`
- `WHERE`
- `AND`, `OR`
- `IN`, `BETWEEN`, `LIKE`
- `ORDER BY`
- `DISTINCT`
- `CASE WHEN`
- `NULL`
- Date/time basics

Bài tập:

- Lấy order theo status.
- Lấy order trong khoảng ngày.
- Phân loại order theo amount.
- Tìm customer thiếu email.

Dấu hiệu đạt:

- Không dùng `= NULL`.
- Không lạm dụng `SELECT *`.
- Biết viết filter ngày dạng `>= start` và `< next_day`.

## 3. Giai đoạn 2: JOIN và aggregation

Mục tiêu:

- Ghép bảng đúng.
- Không làm nhân/mất dữ liệu ngoài ý muốn.
- Tính metric cơ bản đúng.

Cần học:

- `INNER JOIN`
- `LEFT JOIN`
- `FULL JOIN`
- Semi join với `EXISTS`
- Anti join với `NOT EXISTS`
- `COUNT`, `SUM`, `AVG`
- `COUNT DISTINCT`
- `HAVING`
- Conditional aggregation

Bài tập:

- Tính revenue theo customer.
- Tìm customer chưa có order.
- Tìm order thiếu customer dimension.
- Tính cancellation rate.

Dấu hiệu đạt:

- Luôn hỏi grain trước khi join.
- Biết kiểm tra duplicate key.
- Biết vì sao `SUM(order_amount)` sau join item có thể sai.

## 4. Giai đoạn 3: Window functions

Mục tiêu:

- Giải bài toán ranking, dedup, latest record, running total.

Cần học:

- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `LAG`
- `LEAD`
- `FIRST_VALUE`
- `LAST_VALUE`
- Window frame
- `QUALIFY` nếu platform hỗ trợ

Bài tập:

- Lấy order mới nhất mỗi customer.
- Dedup staging table.
- Tính ngày giữa hai lần mua.
- Tính running revenue.
- Tính top 3 product mỗi category.

Dấu hiệu đạt:

- Biết thêm tie-breaker trong `ORDER BY`.
- Biết `LAST_VALUE` cần frame rõ.
- Biết khi nào cần aggregate trước window.

## 5. Giai đoạn 4: Data modeling

Mục tiêu:

- Thiết kế bảng để phục vụ analytics.
- Hiểu fact, dimension, grain, SCD.

Cần học:

- OLTP vs OLAP
- Normalization
- Denormalization
- Star schema
- Fact table
- Dimension table
- Grain
- Natural key vs surrogate key
- SCD Type 1
- SCD Type 2
- Snapshot table
- Bridge table

Bài tập:

- Thiết kế `dim_customer`.
- Thiết kế `fact_order_items`.
- Viết SCD2 join theo `valid_from`, `valid_to`.
- Thiết kế `agg_daily_revenue`.

Dấu hiệu đạt:

- Mỗi bảng bạn tạo đều có grain rõ.
- Biết chọn fact order hay fact order item theo use case.
- Biết khi nào cần lưu lịch sử dimension.

## 6. Giai đoạn 5: ETL/ELT production

Mục tiêu:

- Viết SQL pipeline chạy lại an toàn.
- Xử lý incremental, CDC, backfill.

Cần học:

- Staging/intermediate/mart layers
- Full refresh
- Incremental load
- Watermark
- Idempotency
- `MERGE`
- Dedup before merge
- CDC
- Late arriving data
- Backfill
- Audit columns

Bài tập:

- Load `fact_orders` incremental.
- Dedup `stg_customers`.
- Upsert `dim_customer`.
- Reprocess 7 ngày gần nhất.
- Thiết kế watermark table.

Dấu hiệu đạt:

- Pipeline retry không duplicate.
- Source duplicate không làm merge lỗi.
- Có audit columns.
- Có backfill strategy.

## 7. Giai đoạn 6: Performance tuning

Mục tiêu:

- Đọc được execution plan.
- Biết giảm dữ liệu phải đọc.
- Biết tối ưu query trên bảng lớn.

Cần học:

- Execution plan
- Index
- Full scan vs index scan
- Join strategies
- Predicate pushdown
- Partition pruning
- Statistics
- Data skew
- Sort/hash cost
- Aggregate table/materialized view

Bài tập:

- Rewrite filter ngày có function.
- So sánh `UNION` và `UNION ALL`.
- Tối ưu query dashboard doanh thu.
- Đọc plan và tìm bước tốn nhất.

Dấu hiệu đạt:

- Không tuning theo cảm tính.
- Đo trước/sau.
- Biết full scan không luôn xấu.
- Biết query warehouse khác query OLTP.

## 8. Giai đoạn 7: Data quality và debugging

Mục tiêu:

- Phát hiện dữ liệu sai sớm.
- Debug metric lệch có phương pháp.

Cần học:

- Null check
- Duplicate check
- Referential integrity
- Freshness
- Row count reconciliation
- Sum reconciliation
- Distribution/anomaly check
- Schema drift
- Debug source-target
- Debug join/aggregation/timezone

Bài tập:

- Viết test duplicate primary key.
- Viết test missing dimension.
- Viết test freshness.
- Debug revenue lệch source-target.
- Tạo bảng lưu data quality results.

Dấu hiệu đạt:

- Pipeline có test sau load.
- Incident có root cause rõ.
- Sau incident có thêm check để ngăn lặp lại.

## 9. Giai đoạn 8: Semi-structured data

Mục tiêu:

- Làm việc được với JSON/nested event data.

Cần học:

- JSON object/array
- Flatten/unnest/explode
- `JSON_TABLE`
- `LATERAL FLATTEN`
- `UNNEST`
- Schema drift
- Parse raw to structured

Bài tập:

- Parse raw order JSON.
- Flatten items.
- Thiết kế fact_events từ raw event.
- Kiểm tra missing field.

Dấu hiệu đạt:

- Biết flatten đổi grain.
- Không query dashboard trực tiếp trên raw JSON nếu không cần.
- Có lưu raw payload để debug.

## 10. Giai đoạn 9: Governance và security

Mục tiêu:

- Làm dữ liệu an toàn và có quản trị.

Cần học:

- PII
- Least privilege
- Role-based access
- Masking
- Row-level security
- Column-level security
- Audit log
- Retention
- Lineage
- Data catalog

Bài tập:

- Tạo view che PII.
- Thiết kế role analyst.
- Ghi metadata cho bảng fact.
- Đề xuất retention cho raw logs.

Dấu hiệu đạt:

- Không cấp quyền rộng bừa bãi.
- Biết bảng nào chứa PII.
- Bảng production có owner, grain, SLA.

## 11. Thứ tự học đề xuất trong 12 tuần

### Tuần 1-2

- SQL fundamentals.
- Filter, date, null, case when.
- Bài tập đọc dữ liệu.

### Tuần 3-4

- Join và aggregation.
- Grain, cardinality.
- Revenue/customer/order metrics.

### Tuần 5

- Window functions.
- Dedup, latest record, ranking.

### Tuần 6

- Data modeling.
- Fact/dim/star schema/SCD.

### Tuần 7-8

- ETL/ELT SQL patterns.
- Incremental, merge, backfill, idempotency.

### Tuần 9

- Data quality checks.
- Reconciliation.

### Tuần 10

- Performance tuning.
- Execution plan, partitioning, query rewrite.

### Tuần 11

- Analytical use cases.
- Funnel, retention, cohort, rolling metrics.

### Tuần 12

- Debug incident end-to-end.
- Security/governance basics.
- Tổng hợp portfolio project.

## 12. Portfolio project đề xuất

Xây một mini data warehouse bán hàng.

Nguồn:

- `raw_customers`
- `raw_orders`
- `raw_order_items`
- `raw_events`

Tạo:

- `stg_customers`
- `stg_orders`
- `stg_order_items`
- `dim_customer`
- `dim_product`
- `fact_order_items`
- `agg_daily_revenue`
- `agg_customer_lifetime_value`

Yêu cầu:

- Incremental load.
- Dedup staging.
- SCD Type 2 cho customer city.
- Data quality tests.
- Analytical queries: DAU, revenue, retention.
- Document grain từng bảng.

Đây là project đủ tốt để chứng minh năng lực từ junior lên mid/senior.

## 13. Cách tự đánh giá theo level

### Fresher

- Viết query cơ bản.
- Join đơn giản.
- Aggregate đơn giản.

### Junior

- Hiểu join types.
- Viết window functions cơ bản.
- Làm được ETL đơn giản.

### Middle

- Thiết kế fact/dim.
- Viết incremental pipeline.
- Debug data issues.
- Tối ưu query cơ bản.

### Senior

- Thiết kế model và pipeline production.
- Xử lý scale/performance.
- Định nghĩa data quality strategy.
- Debug incident phức tạp.
- Biết governance/security.
- Review SQL của người khác và phát hiện rủi ro.

## 14. Thói quen học hiệu quả

- Luôn viết SQL với dữ liệu mẫu.
- Sau mỗi query, kiểm tra row count.
- Tự hỏi grain là gì.
- Tự tạo lỗi duplicate để hiểu cách debug.
- Đọc execution plan cho query chậm.
- Viết checklist cho từng loại pipeline.
- Ghi lại metric definition.
- Review SQL cũ và refactor cho dễ đọc.

## 15. Những câu hỏi senior hay tự hỏi

- Bảng này mỗi dòng là gì?
- Query này có làm mất dòng không?
- Query này có làm nhân dòng không?
- Dữ liệu đến muộn thì sao?
- Retry job thì sao?
- Source duplicate thì sao?
- Nếu dashboard sai, debug từ đâu?
- Query này có đọc quá nhiều dữ liệu không?
- Ai được xem dữ liệu này?
- Có test nào phát hiện lỗi này sớm không?

## 16. Kết luận

Để trở thành Senior Data Engineer về SQL, bạn cần đi xa hơn cú pháp.

Bạn cần làm chủ:

- Độ đúng của dữ liệu.
- Mô hình dữ liệu.
- Pipeline production.
- Hiệu năng trên dữ liệu lớn.
- Data quality.
- Debug.
- Security và governance.

SQL là công cụ, nhưng tư duy dữ liệu mới là thứ làm nên senior.

