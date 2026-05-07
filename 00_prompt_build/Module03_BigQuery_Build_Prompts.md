# 5 Prompts Build File Module03_BigQuery_DataWarehouse.html

Cách chạy: Mở terminal → `cd DE-Learning` → `claude` → paste Prompt 1 → chờ xong →
mở file trên browser kiểm tra → paste Prompt 2 → tiếp tục đến Prompt 5.

---

## Prompt 1 — Khởi tạo file + S0 + S1

```
Đọc các file sau trước khi làm bất cứ điều gì:
- .claude/CLAUDE.md
- .claude/OUTPUT_STANDARD.md
- .claude/SOURCE_POLICY.md
- master_de_roadmap.html (phần Module 03 và section 3-Level System)
- module_template.html (lấy TOÀN BỘ CSS variables, font, component patterns)
- data-engineering-zoomcamp/03-data-warehouse/ (đọc README + liệt kê toàn bộ files)

Tạo file mới: Module03_BigQuery_DataWarehouse.html

File phải có:
- Toàn bộ HTML boilerplate: <!DOCTYPE>, <head>, CSS inline, fonts Google
- Copy NGUYÊN XI CSS variables và styles từ module_template.html
- Hero banner: "Module 03 — Data Warehouse & BigQuery", badges (Beginner→Senior, ~7 ngày, Data Warehouse)
- Sidebar với 9 nav items: S0 đến S8 (S0 active mặc định)
- JavaScript: showModule(), toggleSection(), answerQuiz(), toggleSolution(), switchTab(), toggleCheck(), updateProgress()
- Phần main content chứa S0 và S1 đầy đủ, các section S2–S8 để placeholder <div id="sX" style="display:none"></div>

NỘI DUNG S0 — Tổng quan & Mục tiêu:
- Bảng 9 sections với tên + thời gian ước tính
- Vấn đề thực tế Data Warehouse giải quyết:
  "analytics queries trên OLTP database làm chậm production" — giải thích tại sao DW tách biệt
- Trước BigQuery người ta làm gì? (on-prem Hive/Redshift, quản lý cluster phức tạp)
- Data flow diagram ASCII: Source Files (GCS) → External Table → Native Table (Partitioned+Clustered) → Analytics / BQML → Model Serving
- Data flow diagram ASCII: Python Script (web_to_gcs.py) → GCS Bucket → BigQuery → Dashboard
- Exit criteria: "Bạn đã nắm module này khi..."

NỘI DUNG S1 — Lý thuyết nền:

Phần Data Warehouse fundamentals (3 levels):
- Beginner: OLTP vs OLAP — bảng so sánh rõ ràng (mục đích, query pattern, index strategy, normalization)
- Beginner: Data Warehouse là gì, Data Lake là gì, Data Lakehouse là gì — khi nào dùng cái nào
- Intermediate: Column-oriented storage — tại sao BigQuery không dùng row-store, ảnh hưởng gì đến query
- Intermediate: External Table vs Native Table — trade-offs đầy đủ (cost, performance, use case)
- Senior: BigQuery storage internals — Capacitor format, execution tree/stages, slot management
- Senior: On-demand vs Reservations pricing — khi nào dùng cái nào, tính cost
- Mental model 1 câu: "BigQuery = serverless data warehouse, trả tiền theo bytes scanned không phải theo cluster"
- So sánh: BigQuery vs Snowflake vs Redshift vs Databricks — trade-offs thực tế
- Info boxes: tip/warn/note/danger đan xen
- 6 câu quiz scenario-based với explanation đầy đủ

Phần Partitioning & Clustering (3 levels):
- Beginner: Partition là gì, analogy tủ hồ sơ chia ngăn theo năm
- Beginner: Clustering là gì, analogy sắp xếp hồ sơ trong ngăn theo alphabet
- Intermediate: Partition types: DATE/RANGE/INGESTION_TIME — khi nào chọn loại nào
- Intermediate: Clustering key cardinality — chọn cột có cardinality cao hay thấp? Tại sao?
- Senior: Partition pruning mechanics — predicate phải viết thế nào để được pruning
- Senior: Combined partition+cluster — thứ tự tác động performance, benchmark từ repo
  (non-partitioned: 1.6GB scan → partitioned: 106MB → partitioned+clustered: 864MB vs 1.1GB)
- Mental model 1 câu: "Partition cắt theo thời gian, Cluster sắp xếp trong partition theo dimension key"
- 6 câu quiz scenario-based với explanation đầy đủ

Lưu file. Báo cáo số dòng đã tạo.
```

---

## Prompt 2 — Thêm S2 (đọc hiểu code repo)

```
Đọc các file sau:
- Module03_BigQuery_DataWarehouse.html (file đang build, đọc toàn bộ để hiểu structure)
- data-engineering-zoomcamp/03-data-warehouse/ (đọc TOÀN BỘ từng file một)
  Cụ thể phải đọc:
  * 03-data-warehouse/big_query.sql
  * 03-data-warehouse/big_query_hw.sql
  * 03-data-warehouse/big_query_ml.sql
  * 03-data-warehouse/extract_model.md
  * 03-data-warehouse/extras/web_to_gcs.py
  * 03-data-warehouse/extras/web_to_gcs_with_progress_bar.py
  * 03-data-warehouse/extras/pyproject.toml
  * 03-data-warehouse/extras/.env-example
  * 03-data-warehouse/README.md
  * 03-data-warehouse/extras/README.md

Thêm nội dung S2 vào Module03_BigQuery_DataWarehouse.html.
Tìm placeholder <div id="s2" style="display:none"></div> và thay bằng nội dung đầy đủ.

NỘI DUNG S2 — Đọc hiểu code trong repo:

Phần 1 — Cấu trúc thư mục:
- Vẽ tree diagram toàn bộ 03-data-warehouse/
- Giải thích mục đích từng file

Phần 2 — big_query.sql (phân tích NGUYÊN VĂN từ repo):
- Trích code thực tế với syntax highlight SQL
- Giải thích TỪNG query: làm gì, bảng input → output là gì
- Tại sao CREATE OR REPLACE EXTERNAL TABLE lại trỏ vào GCS wildcard (fhv_tripdata_2019-*.csv)?
- Native table vs External table: bảng này khi nào scan data, khi nào không?
- Tại sao phải materialize vào native table trước khi partition+cluster?
- Performance comparison thực tế từ code: non-partitioned vs partitioned query — bytes scanned khác nhau bao nhiêu?

Phần 3 — big_query_hw.sql (phân tích NGUYÊN VĂN từ repo):
- Trích code thực tế với syntax highlight SQL
- Giải thích từng query, đây là file homework hay demo?
- INFORMATION_SCHEMA.PARTITIONS — query này cho biết gì, dùng để làm gì trong thực tế?
- Scan comparison được comment trong file: 1.6GB → 106MB (partition), 1.1GB → 864.5MB (cluster)
  → Tại sao cluster không giảm mạnh bằng partition? Explain cơ chế

Phần 4 — big_query_ml.sql (phân tích NGUYÊN VĂN từ repo):
- Trích code thực tế với syntax highlight SQL
- Flow end-to-end: feature table → CREATE MODEL → EVALUATE → PREDICT → EXPLAIN → Hyperparameter tuning
- Model type: linear_reg — khi nào phù hợp, khi nào không?
- Tại sao phải cast PULocationID/DOLocationID sang STRING?
  → Location ID là category (không có linear ordering), cast về string giúp BQML treat đúng
- ML.EXPLAIN_PREDICT trả về gì, dùng để làm gì trong production?
- Hyperparameter tuning: num_trials, max_parallel_trials, l1_reg, l2_reg — giải thích từng param

Phần 5 — web_to_gcs.py + web_to_gcs_with_progress_bar.py (phân tích NGUYÊN VĂN từ repo):
- Trích code thực tế với syntax highlight Python
- Data flow: source URL → download CSV.GZ → convert Parquet → upload GCS
- Tại sao convert sang Parquet (không giữ CSV)?
  → Columnar storage, compression tốt hơn, BigQuery đọc parquet nhanh hơn CSV
- Khác nhau giữa 2 scripts: progress bar + skip logic nếu file đã tồn tại trên GCS
- Điểm yếu của web_to_gcs.py:
  * Không có raise_for_status() — HTTP error không được phát hiện, ghi file lỗi thành "data"
  * Không có checksum/data quality check sau convert/upload
  * Không có retry policy có chủ đích, structured logging
  * Hard-coded năm list — không linh hoạt
- .env-example: các env vars cần thiết và ý nghĩa từng var

Phần 6 — Data flow tổng hợp:
- Diagram ASCII: web_to_gcs.py → GCS Bucket → BigQuery External Table → Native Table → Analytics/BQML
- Thứ tự chạy đúng từng bước
- Dependency: big_query_ml.sql cần yellow_tripdata_partitioned tồn tại trước
- Dependency: extract_model.md cần model nytaxi.tip_model đã được train

Tabs: SQL / Python / Config — dùng switchTab() function

Quiz: 6 câu về code và data flow, có explanation

Lưu file. Báo cáo số dòng hiện tại.
```

---

## Prompt 3 — Thêm S3 (thực hành)

```
Đọc các file sau:
- Module03_BigQuery_DataWarehouse.html (đọc toàn bộ)
- data-engineering-zoomcamp/03-data-warehouse/ (đọc lại để lấy commands chính xác)
- master_de_roadmap.html (phần M03 — execution plan và Break/Debug examples nếu có)

Thêm nội dung S3 vào Module03_BigQuery_DataWarehouse.html.
Tìm placeholder <div id="s3" style="display:none"></div> và thay bằng nội dung đầy đủ.

NỘI DUNG S3 — Thực hành từng bước:

Phần 1 — Setup môi trường (commands thực tế, copy-paste được):
- Prerequisites: GCP account, project ID, service account key JSON
- Cài GCP SDK: lệnh verify (gcloud --version, gcloud auth application-default login)
- Clone repo + cd vào đúng thư mục
- Setup .env từ .env-example: giải thích từng variable phải điền gì
- uv sync trong thư mục extras: tại sao uv thay vì pip?
- Verify setup thành công: "Bạn biết setup đúng khi thấy..."

Phần 2 — Chạy Python ingestion scripts:
- Step by step với commands thực tế từ repo
- uv run python web_to_gcs_with_progress_bar.py: output mong đợi là gì
- Verify upload thành công: gsutil ls command để kiểm tra GCS
- Chạy web_to_gcs.py: khi nào dùng cái này thay vì bản progress bar

Phần 3 — Chạy SQL trong BigQuery Console:
- Cách mở BigQuery Console, chọn đúng project
- Chạy big_query.sql từng block theo thứ tự: tại sao phải theo thứ tự
- Đọc "Query complete — X seconds elapsed, Y bytes processed": ý nghĩa từng con số
- Verify external table tạo thành công: SELECT count(*) và xem bytes scanned
- Verify partition table: query INFORMATION_SCHEMA.PARTITIONS
- Chạy big_query_ml.sql từng bước: mỗi step mất bao lâu (estimate)

Phần 4 — 3 bài tập thực hành (dùng .practice-task component):

Task 1 (Beginner):
Đề: Tạo external table cho yellow taxi data (2019+2020) thay vì FHV, query count rows và distinct VendorID
Gợi ý: Xem pattern trong big_query_hw.sql, thay dataset/table name
Solution: SQL đầy đủ với giải thích từng dòng

Task 2 (Intermediate):
Đề: Tạo bảng yellow_taxi_partitioned_clustered với partition theo tpep_pickup_datetime VÀ cluster theo payment_type, sau đó viết query chứng minh bytes scanned giảm so với bảng không partition
Gợi ý: Dùng INFORMATION_SCHEMA.PARTITIONS để verify partition tạo đúng
Solution: SQL đầy đủ với expected scan comparison

Task 3 (Advanced):
Đề: Modify web_to_gcs.py để thêm: (1) raise_for_status() khi download, (2) MD5 checksum verify sau upload, (3) structured logging với timestamp và file size
Gợi ý: requests.Response.raise_for_status(), hashlib.md5(), storage.Blob.md5_hash
Solution: Python code đầy đủ với explanation từng thay đổi

Phần 5 — "Cố tình phá" section:
6 kịch bản với hướng dẫn debug từng bước:

1. Query external table mà GCS bucket đã xóa/đổi path
   → Lỗi gì? Tìm error message ở đâu trong BigQuery Console?
   → Tại sao external table không validate data tại thời điểm CREATE?

2. PARTITION BY một cột có NULL values
   → Hàng NULL đi vào partition nào? Kiểm tra bằng INFORMATION_SCHEMA thế nào?
   → BigQuery xử lý NULL partition ra sao (special __NULL__ partition)

3. Query partition table nhưng không dùng partition column trong WHERE
   → Bytes scanned bao nhiêu? Full scan hay pruned?
   → Tại sao predicate YEAR(pickup_date) = 2019 không được pruning nhưng
      DATE(pickup_date) BETWEEN '2019-01-01' AND '2019-12-31' thì được?

4. Chạy big_query_ml.sql khi bảng yellow_tripdata_partitioned chưa tồn tại
   → Error message thực tế, cách fix

5. web_to_gcs.py fail giữa chừng (simulate: Ctrl+C sau khi upload được 3/12 files)
   → Re-run: nó overwrite hay skip files đã upload?
   → Tại sao web_to_gcs_with_progress_bar.py an toàn hơn trong trường hợp này?

6. GOOGLE_APPLICATION_CREDENTIALS trỏ vào file JSON không tồn tại
   → Error message từ Python script vs từ gcloud command
   → Cách verify credentials đang hoạt động: gcloud auth application-default print-access-token

Lưu file. Báo cáo số dòng hiện tại.
```

---

## Prompt 4 — Thêm S4 + S5 (production + nâng cao)

```
Đọc các file sau:
- Module03_BigQuery_DataWarehouse.html (đọc toàn bộ)
- data-engineering-zoomcamp/03-data-warehouse/ (đọc lại code để lấy context chính xác)
- master_de_roadmap.html (phần Production Readiness và Advanced nếu có)

Thêm nội dung S4 và S5 vào Module03_BigQuery_DataWarehouse.html.
Tìm 2 placeholders và thay bằng nội dung đầy đủ.

NỘI DUNG S4 — Production Readiness:
6 câu hỏi "What if this were production?", mỗi câu có phân tích đầy đủ + code example:

1. IDEMPOTENCY: Re-run pipeline có an toàn không?
   - Script hiện tại: CREATE OR REPLACE TABLE → replace toàn bộ mỗi lần chạy
   - Vấn đề: không phù hợp incremental load, tốn cost scan toàn bộ GCS mỗi ngày
   - Fix đúng hướng: partition-based incremental — chỉ load partition của ngày hôm qua
   - Code example: INSERT INTO ... SELECT ... WHERE DATE(pickup_datetime) = CURRENT_DATE - 1
   - Concept: watermark table để track last_processed_partition

2. ERROR HANDLING: Pipeline fail giữa chừng thì sao?
   - web_to_gcs.py hiện tại: không có raise_for_status(), không có retry logic
   - Tác hại: file lỗi HTTP 404/500 có thể được ghi thành "data" vào GCS
   - Fix:
     * raise_for_status() sau mỗi request
     * Retry với exponential backoff (tenacity hoặc google-cloud-storage retry policy)
     * Dead letter: ghi file lỗi vào separate error bucket
   - Code example: tenacity @retry decorator với 3 lần thử, wait_exponential

3. COST CONTROL: Query tốn bao nhiêu và kiểm soát thế nào?
   - Hiểu bytes billed vs bytes processed
   - Dry run: estimate cost trước khi chạy query thật
     * SQL: EXPLAIN SELECT... (không có trong BigQuery, dùng API hoặc Console estimate)
     * Python: job_config.dry_run = True
   - Partition expiration: tự xóa data cũ để tiết kiệm storage
   - Bytes billed cap per query: maximum_bytes_billed trong job config
   - Code example: BigQuery Python client với dry_run và maximum_bytes_billed

4. SECURITY: Những rủi ro trong setup hiện tại?
   - GOOGLE_APPLICATION_CREDENTIALS JSON trên local:
     * Rủi ro: commit nhầm lên git, file bị đánh cắp → attacker có full GCP access
     * Alternative production: Workload Identity Federation (GitHub Actions/GCE/GKE)
     * Nguyên tắc: credentials không nên tồn tại dưới dạng file trên disk
   - Service account least privilege:
     * Scope tối thiểu: roles/storage.objectViewer cho GCS read, roles/bigquery.dataEditor cho BQ
     * Không dùng roles/owner hay roles/editor cho service account pipeline
   - BigQuery IAM: column-level security, row-level security cho sensitive data
   - Code example: IAM policy binding đúng cách với Terraform

5. DATA QUALITY: Làm sao biết data được load đúng?
   - Hiện tại: không có assertion nào sau load
   - Checks cần thiết:
     * Row count: so sánh source files vs loaded rows
     * Null check: cột mandatory không được có NULL
     * Date range: pickup_datetime nằm trong khoảng hợp lý không
     * Schema drift: column thêm/bỏ từ source sẽ gây lỗi gì
   - Code example: BigQuery dbt test equivalent bằng SQL assertion
   - Concept: expect_column_values_to_not_be_null (Great Expectations pattern)

6. MONITORING: Làm sao biết pipeline chạy xong và đúng?
   - BigQuery Job history: tìm failed jobs ở đâu trong Console
   - Cloud Logging: query log ingestion job từ Python với structured log
   - Alert: Cloud Monitoring metric "bigquery.googleapis.com/job/num_in_flight_jobs"
   - Code example: structured logging schema (job_id, dataset, table, rows_loaded, bytes, duration_ms, status)
   - Dead man's switch: alert nếu pipeline KHÔNG chạy trong X giờ

NỘI DUNG S5 — Kiến thức nâng cao:

Phần 1 — BigQuery Internals (Senior must-know):
- Capacitor: columnar format của BigQuery, tại sao không expose schema như Parquet/ORC
- Execution tree: Dremel model — root server, mixer, leaf server; shuffle giữa stages
- Slot: đơn vị compute của BigQuery, tại sao query dùng nhiều slot không luôn nhanh hơn
- Join strategies: broadcast join (small table) vs shuffle join (large table) — BigQuery tự chọn thế nào
- Bảng anti-patterns gây slot contention: cross join, DISTINCT trên bảng lớn, correlated subquery

Phần 2 — BigQuery ML Production (Senior must-know):
- Training-serving skew: model train trên historical data nhưng serve trên real-time features → drift
- Model versioning: làm sao deploy model mới mà không break production (blue/green, champion/challenger)
- Scheduled retraining: BQML không tự retrain — cần Vertex AI Pipelines hoặc Cloud Scheduler
- Online serving: BQML export → TF Serving (extract_model.md) vs Vertex AI Endpoint — trade-offs
- CI/CD cho SQL ML: test feature logic trước khi train, validation threshold cho deploy

Phần 3 — Data Modeling trong Data Warehouse (Senior must-know):
- Star schema: fact table + dimension tables — tại sao BigQuery thích denormalized wide table hơn
- SCD Type 1 vs Type 2:
  * Type 1: overwrite (mất history) — khi nào phù hợp
  * Type 2: add row với valid_from/valid_to — cách implement trong BigQuery
- Partition strategy cho fact tables: date của event hay date of ingestion?
- Late-arriving data: record thuộc ngày hôm qua đến hôm nay → partition nào nhận?

Phần 4 — Bảng Trade-offs (khi DÙNG vs KHÔNG DÙNG):
| Scenario | External Table | Native Table |
| Scenario | Partition by DATE | Partition by RANGE |
| Scenario | Cluster by 1 column | Cluster by 4 columns |
| Scenario | BigQuery ML | Vertex AI custom training |
| Scenario | On-demand pricing | Flat-rate reservations |

Phần 5 — Khi nào outgrow BigQuery setup hiện tại:
- Dấu hiệu cần thêm orchestration: pipeline phụ thuộc nhiều bước, retry phức tạp
- Dấu hiệu cần dbt: SQL transforms phức tạp, cần lineage, testing, documentation
- Dấu hiệu cần Vertex AI thay vì BQML: model phức tạp hơn linear_reg, cần custom training
- Dấu hiệu cần data catalog: nhiều team, nhiều dataset, khó discover/govern data

Lưu file. Báo cáo số dòng hiện tại.
```

---

## Prompt 5 — Thêm S6 + S7 + S8, hoàn thiện file

```
Đọc các file sau:
- Module03_BigQuery_DataWarehouse.html (đọc toàn bộ)
- master_de_roadmap.html (phần Incident Simulation, Interview Mapping, DoD, Final Checklist)

Thêm nội dung S6, S7, S8 vào Module03_BigQuery_DataWarehouse.html.
Tìm 3 placeholders và thay bằng nội dung đầy đủ.

NỘI DUNG S6 — Lỗi thường gặp:

Bảng 11 lỗi, dùng class="data-table":
Cột: Lỗi (error message thực tế) | Nguyên nhân | Cách fix | Cách phòng tránh

11 lỗi phải bao gồm:
1. "Not found: Table project:dataset.table" — query bảng chưa tạo
2. "Access Denied: BigQuery BigQuery: Permission denied" — service account thiếu role
3. "Error while reading data, error message: CSV table encountered too many errors" — external table đọc CSV sai format
4. "Quota exceeded: Your project exceeded quota for free query bytes per day" — vượt free tier 1TB/tháng
5. "Resources exceeded during query execution" — query quá lớn, không đủ slot
6. "Invalid value: Cannot set both a partition filter and scan all partitions" — require_partition_filter mà không dùng partition column trong WHERE
7. INFORMATION_SCHEMA.PARTITIONS trả về 0 rows — tạo bảng xong nhưng chưa có data
8. web_to_gcs.py chạy xong nhưng GCS file size = 0 bytes — HTTP error không được catch
   Nguyên nhân: thiếu raise_for_status(), ghi HTTP error response thành file
   Fix: thêm response.raise_for_status() sau mỗi request
   Phòng tránh: luôn verify file size sau upload, dùng MD5 checksum
9. "google.api_core.exceptions.Forbidden: 403 POST... does not have storage.objects.create access" — GOOGLE_APPLICATION_CREDENTIALS sai hoặc thiếu quyền GCS write
10. big_query_ml.sql báo lỗi "Table not found: yellow_tripdata_partitioned" — chạy ML script trước khi tạo feature table
    Fix: luôn chạy theo thứ tự: web_to_gcs → big_query.sql → big_query_ml.sql
11. Partition pruning không hoạt động — bytes scanned vẫn full scan dù có partition
    Nguyên nhân: dùng YEAR(pickup_datetime) = 2019 thay vì DATE(pickup_datetime) BETWEEN ...
    Fix: viết predicate trực tiếp trên partition column, không wrap trong function
    Phòng tránh: luôn check "bytes processed" sau query, compare với expectation

Sau bảng: Debugging checklist theo thứ tự ưu tiên (numbered list):
1. Check job history trong BigQuery Console (xem error message đầy đủ)
2. Verify credentials: gcloud auth application-default print-access-token
3. Verify GCS path: gsutil ls gs://your-bucket/path/
4. Verify table tồn tại: SELECT * FROM dataset.INFORMATION_SCHEMA.TABLES
5. Check bytes scanned: có partition pruning không?
6. Check IAM: service account có đúng roles không?

NỘI DUNG S7 — Interview Prep:

12 câu hỏi, dùng toggleSection hoặc collapsible pattern:

Junior (4 câu — badge xanh lam):
1. Data Warehouse khác Database thông thường ở điểm nào cơ bản nhất?
2. External Table và Native Table trong BigQuery khác nhau thế nào?
3. Tại sao BigQuery tính tiền theo bytes scanned chứ không phải theo thời gian chạy?
4. Partition và Clustering trong BigQuery là gì? Khi nào nên dùng?

Mid (4 câu — badge vàng):
5. Tại sao predicate YEAR(pickup_date) = 2019 không được partition pruning nhưng DATE(pickup_date) BETWEEN '2019-01-01' AND '2019-12-31' thì được?
6. Pipeline ingest data vào BigQuery bị fail sau khi đã load 60% — restart toàn bộ hay tiếp tục từ điểm dừng? Design solution
7. Tại sao nên convert CSV sang Parquet trước khi upload GCS thay vì để CSV trực tiếp?
8. BQML linear_reg dự đoán tip_amount — khi nào model này không phù hợp và cần chuyển sang model khác?

Senior (4 câu — badge đỏ):
9. Thiết kế BigQuery schema cho 10TB fact table taxi trips, đảm bảo:
   (a) query analytics theo ngày dưới 10 giây, (b) cost dưới $50/ngày, (c) incremental daily load
10. Service account key JSON bị commit nhầm lên public GitHub repo — incident response thế nào? (bước từng phút)
11. Team analytics query cùng một BigQuery dataset, bill tháng này $15,000, CEO hỏi tại sao — điều tra và đề xuất giải pháp
12. BQML model đang production, accuracy drop 20% sau 3 tháng — nguyên nhân có thể là gì và xử lý thế nào?

Mỗi câu: click expand → gợi ý trả lời chi tiết + "Red flag: đừng nói..."

NỘI DUNG S8 — Checklist & Tổng kết:

Progress bar (tự update khi tick):
ID: checklist-progress-fill và checklist-progress-text

Checklist 18 items chia 3 level:

Beginner (6 items):
- Giải thích được OLTP vs OLAP cho người không biết IT
- Tạo được External Table từ GCS wildcard trong BigQuery Console
- Chạy được web_to_gcs.py và verify file xuất hiện trong GCS
- Hiểu bytes scanned là gì và tìm thấy con số này sau mỗi query
- Tạo được bảng Partitioned + Clustered từ External Table
- Biết .env file là gì và tại sao không commit lên git

Intermediate (6 items):
- Chứng minh được partition pruning bằng số bytes scanned thực tế (trước vs sau)
- Tạo được BQML model, evaluate, predict với big_query_ml.sql
- Query INFORMATION_SCHEMA.PARTITIONS và giải thích output
- Modify web_to_gcs.py để thêm raise_for_status() và retry logic
- Giải thích tại sao convert sang Parquet thay vì giữ CSV
- Biết minimum IAM roles cần thiết cho pipeline này

Senior (6 items):
- Thiết kế incremental load strategy (watermark, partition-based) cho pipeline daily
- Implement dry run và maximum_bytes_billed trong Python client
- Viết SQL data quality assertions (row count, null check, date range)
- Giải thích BigQuery slot model và tại sao nhiều slot không luôn nhanh hơn
- Trả lời được 4 câu Senior interview không cần nhìn tài liệu
- Giải thích trade-off BQML vs Vertex AI custom training cho người mới

Summary grid (5 điểm chốt):
1. BigQuery = serverless columnar DW, trả tiền theo bytes scanned — thiết kế để minimize scan
2. Partition cắt theo thời gian, Cluster sắp xếp trong partition — predicate phải viết đúng cách để được pruning
3. External Table → Native Table là flow chuẩn — External tiện để explore, Native để tối ưu production
4. Idempotency số 1: CREATE OR REPLACE là quick fix, incremental partition load mới là production pattern
5. AWS/Snowflake mapping — kiến thức transfer được:
   GCS → S3, BigQuery Dataset → Redshift Schema, BigQuery ML → SageMaker Autopilot,
   External Table → Redshift Spectrum / Athena

Definition of Done (từ master_de_roadmap.html):
5 checkboxes DoD — tick đủ mới được sang Module 04

Preview Module 04:
"Module tiếp theo: Analytics Engineering với dbt
Cần chuẩn bị: BigQuery đang hoạt động (module này), hiểu khái niệm SQL transform cơ bản"
Link: <a href="Module04_Analytics_Engineering.html">→ Module 04: Analytics Engineering</a>

SAU KHI THÊM XONG 3 SECTIONS:
Kiểm tra toàn bộ file:
- Tất cả JavaScript functions hoạt động đúng không
- Sidebar navigation showModule() đúng index chưa
- Progress bar updateProgress() được gọi đúng chưa
- Không còn placeholder nào chưa điền
- File mở được trên browser không lỗi console

Lưu file. Báo cáo số dòng cuối cùng và tóm tắt những gì đã build.
```

---

## Prompt Patch (chạy sau nếu cần bổ sung)

```
Đọc các file sau trước khi làm:
- Module03_BigQuery_DataWarehouse.html (đọc toàn bộ để hiểu structure hiện tại)
- data-engineering-zoomcamp/03-data-warehouse/big_query_ml.sql
- data-engineering-zoomcamp/03-data-warehouse/extras/web_to_gcs.py

Thực hiện 5 bổ sung sau vào file. Không được thay đổi bất cứ nội dung nào đã có —
chỉ TÌM ĐÚNG VỊ TRÍ và CHÈN THÊM.

BỔ SUNG 1 — Trong S2, phần phân tích big_query_ml.sql
Tìm đoạn kết thúc phân tích big_query_ml.sql. Chèn thêm sau đó:
- Tại sao cast PULocationID/DOLocationID sang STRING trong feature table?
  → Location ID là identifier, không có linear ordering (ID 1 không "nhỏ hơn" ID 2 theo nghĩa thực).
    Nếu để numeric, model sẽ treat như continuous variable → feature sai.
    Cast sang STRING → BQML auto one-hot encode → đúng cách.
- ML.FEATURE_INFO trả về gì?
  → Distribution của từng feature: mean, stddev, null_count, category_count.
    Dùng để detect skewed features và missing values trước khi train.

BỔ SUNG 2 — Trong S2, phần phân tích web_to_gcs.py
Tìm đoạn "Điểm yếu của web_to_gcs.py". Chèn thêm sau đó:
- Tại sao không dùng pandas read_csv trực tiếp mà phải download về local trước?
  → File .csv.gz từ GitHub release rất lớn (100MB+).
    Streaming parse thẳng vào pandas tiêu tốn RAM, không stable với file lớn.
    Download về disk trước → đọc từng chunk → convert parquet → upload là pattern an toàn hơn.
- pyarrow vs fastparquet — web_to_gcs.py dùng cái nào và tại sao?
  → Cần đọc code thực tế để confirm, ghi rõ engine được dùng và trade-off.

BỔ SUNG 3 — Trong S3, phần "Cố tình phá", kịch bản cuối cùng
Chèn thêm kịch bản thứ 7 sau kịch bản thứ 6:
- Thay đổi schema của GCS parquet file (thêm cột mới) rồi query External Table cũ
  → Lỗi: schema mismatch hoặc new column trả về NULL
  → Tại sao: External Table giữ schema tại thời điểm CREATE, không auto-detect schema mới
  → Fix: DROP và CREATE OR REPLACE EXTERNAL TABLE để refresh schema
  → Production lesson: schema evolution cần version control và migration plan

BỔ SUNG 4 — Trong S4, câu 4 SECURITY
Tìm phần trả lời câu hỏi Security (câu 4) trong S4. Chèn thêm vào cuối:
- Column-level security trong BigQuery:
  → Dùng Policy Tags (Data Catalog) để mask sensitive columns (PII, payment info)
  → User không có permission chỉ thấy NULL hoặc masked value, không thể bypass bằng SELECT *
  → Quan trọng hơn row-level security trong nhiều use case analytics
- BigQuery Authorized Views:
  → Cách expose một subset data cho team khác mà không share full dataset access
  → Pattern: raw data team A → authorized view → team B chỉ thấy aggregated/filtered view

BỔ SUNG 5 — Trong S8, phần Summary grid
Tìm "Summary grid" hoặc phần "5 điểm chốt" trong S8.
5 điểm đã có. Thêm điểm thứ 6 vào cuối:
- BigQuery ML là entry point, bukan destination:
  linear_reg trong repo đủ để hiểu workflow, nhưng production ML cần
  Vertex AI Pipelines + Feature Store + Model Registry + Monitoring.
  Biết khi nào cần "graduate" khỏi BQML là dấu hiệu Senior DE.

SAU KHI THÊM XONG:
1. Kiểm tra file mở được trên browser không lỗi console
2. Kiểm tra 5 vị trí vừa chèn hiển thị đúng style với phần xung quanh
3. Báo cáo: số dòng trước và sau khi patch, vị trí chính xác (line number) của từng bổ sung
```
