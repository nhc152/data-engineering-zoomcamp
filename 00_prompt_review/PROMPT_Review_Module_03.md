# PROMPT_Review_Module_03.md
# Review toàn diện file Module03_BigQuery_DataWarehouse.html

> Dùng cho: Antigravity review code sau khi Claude build xong 5 prompts
> Mục tiêu: Phát hiện lỗi kỹ thuật, nội dung sai, UX hỏng, thiếu sót so với spec
> Cách chạy: Paste toàn bộ prompt này vào Antigravity sau khi có file .html

---

## BƯỚC 0 — ĐỌC FILE TRƯỚC KHI LÀM BẤT CỨ ĐIỀU GÌ

```
Đọc TOÀN BỘ các file sau theo thứ tự:

1. Module03_BigQuery_DataWarehouse.html     ← file cần review
2. module_template.html                     ← chuẩn gốc về CSS/component
3. master_de_roadmap.html                   ← spec Module 03 và DoD
4. data-engineering-zoomcamp/03-data-warehouse/big_query.sql
5. data-engineering-zoomcamp/03-data-warehouse/big_query_hw.sql
6. data-engineering-zoomcamp/03-data-warehouse/big_query_ml.sql
7. data-engineering-zoomcamp/03-data-warehouse/extras/web_to_gcs.py
8. data-engineering-zoomcamp/03-data-warehouse/extras/web_to_gcs_with_progress_bar.py
9. data-engineering-zoomcamp/03-data-warehouse/extras/.env-example

KHÔNG bắt đầu review cho đến khi đã đọc xong tất cả 9 file.
Mục đích: review phải đối chiếu HTML với source code thực tế,
không thể review đúng nếu chỉ đọc HTML một mình.
```

---

## BƯỚC 1 — KIỂM TRA KỸ THUẬT HTML/CSS/JS

```
Kiểm tra toàn bộ phần kỹ thuật của file. Với mỗi mục, ghi rõ:
PASS / FAIL / WARNING + mô tả cụ thể nếu không pass.

═══════════════════════════════
1.1 HTML STRUCTURE
═══════════════════════════════

□ File có đúng DOCTYPE html không?
□ <head> có đủ: charset UTF-8, viewport meta, title, Google Fonts link?
□ Title tag đúng: "Module 03 — Data Warehouse & BigQuery"?
□ Không có broken tag nào (thẻ mở không có thẻ đóng)?
□ Tất cả 9 section div tồn tại: id="s0" đến id="s8"?
□ Không còn placeholder nào dạng <div id="sX" style="display:none"></div>
  còn trống (chưa có nội dung bên trong)?

═══════════════════════════════
1.2 CSS VARIABLES
═══════════════════════════════

So sánh với module_template.html — kiểm tra từng biến:
□ --color-primary tồn tại và đúng giá trị?
□ --color-secondary tồn tại và đúng giá trị?
□ --color-accent tồn tại và đúng giá trị?
□ --color-bg, --color-surface, --color-border tồn tại?
□ --font-main, --font-mono tồn tại?
□ --radius, --shadow tồn tại?
□ Tất cả component classes từ template có trong file:
  .hero-banner, .sidebar, .nav-item, .section-content,
  .info-box (tip/warn/note/danger), .quiz-block, .practice-task,
  .data-table, .code-block, .tab-container, .checklist-item,
  .badge, .progress-bar?
□ Không có CSS custom nào override template theo cách gây visual bug?

═══════════════════════════════
1.3 JAVASCRIPT FUNCTIONS
═══════════════════════════════

□ showModule(index) tồn tại và hoạt động đúng không?
  → Test: click S1 → S1 hiện, S0 ẩn, nav item S1 active
□ toggleSection(id) tồn tại?
  → Dùng cho collapsible sections trong S7 interview?
□ answerQuiz(questionId, answer, correct) tồn tại?
  → Click đáp án đúng → hiển thị đúng/sai + explanation?
□ toggleSolution(taskId) tồn tại?
  → Dùng trong S3 practice tasks?
□ switchTab(tabGroup, tabName) tồn tại?
  → Dùng trong S2 (SQL/Python/Config tabs)?
□ toggleCheck(itemId) tồn tại?
  → Dùng cho checklist S8?
□ updateProgress() tồn tại và được gọi sau mỗi toggleCheck?
  → Progress bar S8 tự cập nhật khi tick?
□ Không có lỗi JavaScript nào (undefined function, syntax error)?
□ Không có lỗi console khi mở file trên browser?

═══════════════════════════════
1.4 NAVIGATION & SIDEBAR
═══════════════════════════════

□ Sidebar có đủ 9 nav items: S0 đến S8?
□ Tên từng nav item đúng:
  S0: Tổng quan & Mục tiêu
  S1: Lý thuyết nền
  S2: Đọc hiểu code repo
  S3: Thực hành từng bước
  S4: Production Readiness
  S5: Kiến thức nâng cao
  S6: Lỗi thường gặp
  S7: Interview Prep
  S8: Checklist & Tổng kết
□ S0 active mặc định khi mở file?
□ Click từng nav item → đúng section hiện lên?
□ Không có nav item nào click → màn hình trắng hoặc lỗi?

═══════════════════════════════
1.5 RESPONSIVE & VISUAL
═══════════════════════════════

□ File mở được trên Chrome/Firefox không lỗi layout?
□ Sidebar và main content không overlap nhau?
□ Code blocks có syntax highlight (hoặc ít nhất monospace font)?
□ Tables không tràn ra ngoài container?
□ Info boxes (tip/warn/note/danger) hiển thị đúng màu?
□ Badge colors đúng: Junior=xanh lam, Mid=vàng, Senior=đỏ?
□ Progress bar S8 render đúng (không bị 0% cứng đờ)?

Báo cáo tất cả FAIL và WARNING với dòng code cụ thể (line number).
```

---

## BƯỚC 2 — KIỂM TRA NỘI DUNG TỪNG SECTION

```
Đọc từng section, đối chiếu với spec build prompt và source code thực tế.
Format báo cáo: ✅ PASS | ⚠️ WARNING | ❌ FAIL

═══════════════════════════════
S0 — TỔNG QUAN & MỤC TIÊU
═══════════════════════════════

□ Có bảng 9 sections với tên + thời gian ước tính không?
□ Có giải thích vấn đề OLTP vs Analytics DW không?
  (analytics query trên production DB làm chậm hệ thống)
□ Có giải thích "trước BigQuery người ta làm gì"
  (Hive on-prem, cluster management, Redshift) không?
□ Có data flow diagram ASCII không? Kiểm tra 2 flow:
  Flow A: Source Files (GCS) → External Table → Native Table → Analytics/BQML
  Flow B: web_to_gcs.py → GCS Bucket → BigQuery → Dashboard
□ Có Exit criteria "Bạn đã nắm module này khi..." không?

═══════════════════════════════
S1 — LÝ THUYẾT NỀN
═══════════════════════════════

Phần Data Warehouse Fundamentals:
□ Có bảng OLTP vs OLAP với ít nhất 4 chiều so sánh không?
  (mục đích, query pattern, normalization, index strategy)
□ Có giải thích Data Lake vs Data Warehouse vs Data Lakehouse không?
□ Có giải thích column-oriented storage tại sao BigQuery dùng không?
□ Có bảng External Table vs Native Table với trade-offs không?
□ Có phần Senior về BigQuery storage internals (Capacitor, Dremel, slots) không?
□ Có mental model 1 câu: "BigQuery = serverless data warehouse..." không?
□ Có bảng so sánh BigQuery vs Snowflake vs Redshift vs Databricks không?
□ Có đủ 6 câu quiz với explanation không?

Phần Partitioning & Clustering:
□ Có analogy tủ hồ sơ cho Partition không?
□ Có analogy sắp xếp alphabet trong ngăn cho Clustering không?
□ Có giải thích 3 loại partition (DATE/RANGE/INGESTION_TIME) không?
□ Có giải thích cardinality khi chọn clustering key không?
□ Có phần Senior về partition pruning mechanics không?
□ Có benchmark thực tế từ repo không? Kiểm tra 3 con số:
  → non-partitioned: 1.6GB scan
  → partitioned: ~106MB scan
  → partitioned+clustered: 864.5MB vs 1.1GB
□ Có mental model 1 câu: "Partition cắt theo thời gian..." không?
□ Có đủ 6 câu quiz với explanation không?

═══════════════════════════════
S2 — ĐỌC HIỂU CODE REPO
═══════════════════════════════

□ Có tree diagram thư mục 03-data-warehouse/ không?
  Kiểm tra có đủ: big_query.sql, big_query_hw.sql, big_query_ml.sql,
  extract_model.md, extras/ với các file bên trong.

Phần big_query.sql:
□ Có trích code SQL thực tế từ repo không?
  Verify bằng cách đối chiếu với file gốc — phải khớp NGUYÊN VĂN:
  * CREATE OR REPLACE EXTERNAL TABLE fhv_tripdata với URI gs://nyc-tl-data/trip data/fhv_tripdata_2019-*.csv
  * CREATE OR REPLACE TABLE fhv_nonpartitioned_tripdata AS SELECT *
  * CREATE OR REPLACE TABLE fhv_partitioned_tripdata PARTITION BY DATE(dropoff_datetime) CLUSTER BY dispatching_base_num
□ Có giải thích tại sao materilaize vào native table trước khi partition không?
□ Có giải thích wildcard URI (*) trong EXTERNAL TABLE không?

Phần big_query_hw.sql:
□ Có trích code SQL và giải thích không?
□ Có giải thích INFORMATION_SCHEMA.PARTITIONS query dùng để làm gì không?
□ Có giải thích tại sao cluster không giảm scan mạnh như partition không?

Phần big_query_ml.sql:
□ Có trích code ML SQL và giải thích flow end-to-end không?
  Flow phải có: feature table → CREATE MODEL → EVALUATE → PREDICT → EXPLAIN → hyperparam tuning
□ Có giải thích tại sao cast PULocationID/DOLocationID sang STRING không?
  (location ID là category, không có linear ordering)
□ Có giải thích ML.EXPLAIN_PREDICT trả về gì không?
□ Có giải thích các hyperparameter: num_trials, max_parallel_trials, l1_reg, l2_reg không?

Phần web_to_gcs.py:
□ Có trích code Python thực tế từ repo không?
  Verify: import os, requests, pandas, google.cloud.storage, dotenv
  Verify: hàm upload_to_gcs(bucket, object_name, local_file)
  Verify: hàm web_to_gcs(year, service) loop 12 tháng
□ Có giải thích tại sao convert CSV.GZ → Parquet không?
  (columnar storage, compression, BigQuery đọc nhanh hơn)
□ Có liệt kê điểm yếu của script không? Kiểm tra ít nhất 3 trong số:
  * Không có raise_for_status()
  * Không có checksum sau upload
  * Không có retry policy
  * Hard-coded năm list
□ Có giải thích .env-example và từng env var không?

Phần web_to_gcs_with_progress_bar.py:
□ Có so sánh khác gì với web_to_gcs.py không?
  (progress bar + skip logic nếu file đã tồn tại)

□ Có tabs SQL/Python/Config dùng switchTab() không?
□ Có data flow diagram tổng hợp không?
□ Có thứ tự chạy đúng và dependency không?
□ Có 6 câu quiz không?

═══════════════════════════════
S3 — THỰC HÀNH TỪNG BƯỚC
═══════════════════════════════

□ Có hướng dẫn setup môi trường với commands thực tế không?
  (gcloud auth, clone repo, uv sync, .env setup)
□ Có section "Verify setup thành công: Bạn biết setup đúng khi thấy..." không?
□ Có hướng dẫn chạy Python ingestion scripts step by step không?
□ Có hướng dẫn chạy SQL trong BigQuery Console không?
□ Có đủ 3 practice tasks với toggleSolution() không?
  Task 1 (Beginner): external table yellow taxi
  Task 2 (Intermediate): partition+cluster + bytes comparison
  Task 3 (Advanced): modify web_to_gcs.py thêm error handling
□ Có "Cố tình phá" section với ít nhất 6 kịch bản không?
  Kiểm tra kịch bản QUAN TRỌNG nhất phải có:
  * Query external table khi GCS bucket bị xóa
  * PARTITION BY cột có NULL values → __NULL__ partition
  * Partition pruning không hoạt động khi dùng YEAR() wrap
  * big_query_ml.sql chạy trước khi bảng yellow_tripdata_partitioned tồn tại
  * web_to_gcs.py fail giữa chừng → re-run behavior

═══════════════════════════════
S4 — PRODUCTION READINESS
═══════════════════════════════

□ Có đủ 6 câu hỏi "What if this were production?" không?
□ Câu IDEMPOTENCY: có giải thích CREATE OR REPLACE vs incremental partition load không?
  Phải có code example INSERT INTO ... WHERE DATE(...) = CURRENT_DATE - 1
□ Câu ERROR HANDLING: có giải thích thiếu raise_for_status() gây hại gì không?
  Phải có code example tenacity @retry hoặc exponential backoff
□ Câu COST CONTROL: có dry_run và maximum_bytes_billed không?
  Phải có code example Python BigQuery client với dry_run = True
□ Câu SECURITY: có 2 điểm quan trọng sau không?
  * Service account JSON key rủi ro + alternative Workload Identity Federation
  * BigQuery IAM least privilege roles cụ thể
    (roles/storage.objectViewer, roles/bigquery.dataEditor — KHÔNG dùng roles/editor)
□ Câu DATA QUALITY: có ít nhất 4 loại check không?
  (row count, null check, date range, schema drift)
□ Câu MONITORING: có structured logging schema không?
  (job_id, dataset, table, rows_loaded, bytes, duration_ms, status)

═══════════════════════════════
S5 — KIẾN THỨC NÂNG CAO
═══════════════════════════════

□ Có phần BigQuery Internals với ít nhất: Capacitor, Dremel model, slot, join strategy?
□ Có phần BigQuery ML Production với:
  training-serving skew, model versioning, scheduled retraining?
□ Có phần Data Modeling trong DW với:
  Star schema, SCD Type 1 vs Type 2, late-arriving data?
□ Có bảng Trade-offs ít nhất 5 scenarios
  (External vs Native, DATE vs RANGE partition, BQML vs Vertex AI, On-demand vs Flat-rate)?
□ Có phần "Khi nào outgrow setup hiện tại" với
  dấu hiệu cần orchestration, dbt, Vertex AI, Data Catalog?

═══════════════════════════════
S6 — LỖI THƯỜNG GẶP
═══════════════════════════════

□ Có bảng data-table với đủ 4 cột:
  Lỗi | Nguyên nhân | Cách fix | Cách phòng tránh?
□ Có đủ 11 lỗi không? Kiểm tra 3 lỗi QUAN TRỌNG nhất phải có:
  * "web_to_gcs.py chạy xong nhưng GCS file size = 0 bytes"
    Nguyên nhân: thiếu raise_for_status()
  * "Partition pruning không hoạt động — vẫn full scan"
    Nguyên nhân: dùng YEAR() wrap thay vì predicate trực tiếp
  * "big_query_ml.sql Table not found: yellow_tripdata_partitioned"
    Nguyên nhân: chạy sai thứ tự
□ Có debugging checklist theo thứ tự ưu tiên (numbered list) không?

═══════════════════════════════
S7 — INTERVIEW PREP
═══════════════════════════════

□ Có đủ 12 câu hỏi không?
□ Có phân chia Junior (4)/Mid (4)/Senior (4) với badge màu đúng không?
□ Mỗi câu có collapsible → gợi ý trả lời chi tiết không?
□ Mỗi câu có "Red flag: đừng nói..." không?
□ Kiểm tra 4 câu Senior quan trọng nhất phải có:
  * Thiết kế schema 10TB với query <10s, cost <$50/ngày, incremental load
  * Service account key bị commit lên public GitHub — incident response
  * BigQuery bill $15,000/tháng — điều tra và giải pháp
  * BQML model accuracy drop 20% sau 3 tháng — nguyên nhân và xử lý

═══════════════════════════════
S8 — CHECKLIST & TỔNG KẾT
═══════════════════════════════

□ Có progress bar với id="checklist-progress-fill" và id="checklist-progress-text" không?
□ Có đủ 18 checklist items chia 3 level (6/6/6) không?
□ Checklist items có id duy nhất và toggleCheck() hoạt động không?
□ updateProgress() được gọi sau mỗi tick không?
□ Có Summary grid với đủ 5 điểm chốt không?
  Kiểm tra điểm số 5 phải có AWS/Snowflake mapping:
  GCS→S3, BigQuery Dataset→Redshift Schema, BQML→SageMaker Autopilot
□ Có Definition of Done với 5 checkboxes không?
□ Có Preview Module 04 với link Module04_Analytics_Engineering.html không?
  Text: "Module tiếp theo: Analytics Engineering với dbt"
```

---

## BƯỚC 3 — FACT-CHECK KỸ THUẬT

```
Đây là phần quan trọng nhất. Đối chiếu từng claim kỹ thuật trong HTML
với source code thực tế trong repo. Ghi rõ từng sai lệch.

═══════════════════════════════
3.1 SQL ACCURACY — đối chiếu với big_query.sql và big_query_hw.sql
═══════════════════════════════

Kiểm tra từng con số scan trong HTML có khớp với comment trong repo không:

□ non-partitioned yellow taxi scan = 1.6GB
  (câu query SELECT DISTINCT(VendorID) với WHERE DATE(tpep_pickup_datetime) BETWEEN...)
□ partitioned yellow taxi scan = ~106MB (câu query tương tự trên partitioned table)
□ partitioned query count trips = 1.1GB
  (câu query count(*) WHERE DATE BETWEEN '2019-06-01' AND '2020-12-31' AND VendorID=1)
□ partitioned+clustered count trips = 864.5MB (câu query tương tự trên clustered table)

Kiểm tra SQL syntax trong HTML không bị sai so với repo:
□ PARTITION BY DATE(dropoff_datetime) — cho FHV table, không phải tpep_pickup_datetime
□ PARTITION BY DATE(tpep_pickup_datetime) — cho Yellow taxi table
□ CLUSTER BY dispatching_base_num — cho FHV table
□ CLUSTER BY VendorID — cho Yellow taxi hw table
□ URI đúng: gs://nyc-tl-data/trip data/fhv_tripdata_2019-*.csv
  (có khoảng trắng trong "trip data" — lỗi phổ biến khi copy)

═══════════════════════════════
3.2 BQML ACCURACY — đối chiếu với big_query_ml.sql
═══════════════════════════════

□ Model type đúng: linear_reg (không phải logistic_reg hay neural_net)
□ Label column đúng: tip_amount (không phải fare_amount hay total_amount)
□ Features đúng: passenger_count, trip_distance, PULocationID, DOLocationID,
  payment_type, fare_amount, tolls_amount
□ Filter condition đúng: WHERE fare_amount != 0
  (không phải WHERE tip_amount > 0 — mục đích khác nhau)
□ DATA_SPLIT_METHOD đúng: AUTO_SPLIT
□ Hyperparameter model: num_trials=5, max_parallel_trials=2
□ l1_reg range: hparam_range(0, 20)
□ l2_reg candidates: hparam_candidates([0, 0.1, 1, 10])
□ ML.EXPLAIN_PREDICT struct đúng: STRUCT(3 as top_k_features)

═══════════════════════════════
3.3 PYTHON ACCURACY — đối chiếu với web_to_gcs.py
═══════════════════════════════

□ Tên hàm đúng: upload_to_gcs(bucket, object_name, local_file)
□ Tên hàm đúng: web_to_gcs(year, service)
□ Base URL đúng: https://github.com/DataTalksClub/nyc-tlc-data/releases/download/
□ GCS path pattern đúng: {service}/{parquet_file}
□ Libraries đúng: requests, pandas, google.cloud.storage, dotenv
□ Không bịa thêm argument hay return value không có trong code thực tế
□ Dtype map trong HTML có khớp với dtypes dict trong repo không?
  Key các cột: VendorID, RatecodeID, PULocationID, DOLocationID,
  passenger_count, payment_type, trip_type — đều là "Int64" (nullable)
□ engine='pyarrow' trong to_parquet() — đúng không?

═══════════════════════════════
3.4 CONCEPT ACCURACY
═══════════════════════════════

□ Giải thích về partition pruning: "YEAR(date) không được pruning nhưng
  DATE(date) BETWEEN ... thì được" — đây là ĐÚNG, verify HTML phát biểu đúng không?
□ Giải thích về Capacitor format: đây là columnar format của BigQuery — đúng không?
□ Giải thích về Dremel: root server → mixer → leaf server — đúng không?
□ Giải thích cast STRING cho location IDs:
  "location ID là category, không có linear ordering" — phát biểu đúng không?
□ Giải thích External Table không có data ở BigQuery storage — đúng không?
  (data vẫn ở GCS, BigQuery chỉ đọc trực tiếp khi query)
□ Giải thích NULL partition trong BigQuery được gọi là __NULL__ partition — đúng không?

Liệt kê mọi claim kỹ thuật SAI trong HTML, kèm:
- Câu/đoạn sai trong HTML (line number nếu có)
- Giá trị đúng từ source code/repo
- Cách fix
```

---

## BƯỚC 4 — KIỂM TRA UX & COMPLETENESS

```
═══════════════════════════════
4.1 COMPLETENESS CHECK
═══════════════════════════════

□ File có đủ tất cả 9 sections có nội dung thực (không còn placeholder trống)?
□ Tổng số dòng hợp lý cho một module đầy đủ (ít nhất 1500 dòng)?
□ Không có section nào "quá mỏng" — ít hơn 50 dòng HTML?
□ Không có đoạn nào bị cắt giữa chừng (truncated mid-sentence)?
□ Tất cả code blocks có đóng tag đúng (</code>, </pre>)?
□ Tất cả tables có đóng tag đúng (</tr>, </td>, </table>)?

═══════════════════════════════
4.2 CONSISTENCY CHECK
═══════════════════════════════

□ Thuật ngữ nhất quán xuyên suốt:
  "External Table" hay "external table" — phải nhất quán
  "BigQuery ML" hay "BQML" — phải nhất quán hoặc giải thích abbrev
  "GCS" hay "Google Cloud Storage" — phải nhất quán
□ Tên file nhất quán: web_to_gcs.py (không phải web_to_gcs_py hay webToGCS)
□ Dataset name nhất quán: nytaxi (không lúc thế này lúc thế khác)
□ Project name: taxi-rides-ny (dùng trong SQL code) — nhất quán?
□ Scan numbers nhất quán: nếu S1 nói 106MB thì S3 không được nói 106GB

═══════════════════════════════
4.3 UX CHECK
═══════════════════════════════

□ Quiz questions không bị lặp nhau giữa S1 và S2?
□ Practice tasks trong S3 có độ khó tăng dần thực sự không?
  (Task 1 < Task 2 < Task 3)
□ "Cố tình phá" kịch bản có thực sự hướng dẫn debug step-by-step không?
  (không chỉ liệt kê lỗi mà phải có "tìm log ở đâu, check gì trước")
□ Interview S7: câu Senior có đủ phức tạp không?
  (không phải câu Junior viết lại thành Senior bằng cách thêm chữ "design")
□ Checklist S8 items có actionable và verifiable không?
  (không phải "hiểu BigQuery" — phải là "chứng minh được partition pruning bằng bytes scanned")
□ Links nội bộ (href="#s3", v.v.) hoạt động đúng không?
□ Link Preview Module 04 có href="Module04_Analytics_Engineering.html" không?
```

---

## BƯỚC 5 — BÁO CÁO & FIX

```
Sau khi hoàn thành Bước 1-4, tạo báo cáo theo format sau:

═══════════════════════════════════════════════════════════
REVIEW REPORT — Module03_BigQuery_DataWarehouse.html
═══════════════════════════════════════════════════════════

TỔNG QUAN:
- Tổng số dòng file: ___
- Tổng số lỗi FAIL: ___
- Tổng số WARNING: ___
- Đánh giá tổng thể: [ ] Đạt — deploy được | [ ] Cần fix trước khi dùng

───────────────────────────────
NHÓM 1: LỖI KỸ THUẬT (phải fix ngay)
───────────────────────────────
Liệt kê từng FAIL từ Bước 1 và Bước 3:
[F01] [Loại lỗi] [Line number nếu có] [Mô tả] [Cách fix]
[F02] ...

───────────────────────────────
NHÓM 2: NỘI DUNG SAI/THIẾU (phải fix trước khi dùng)
───────────────────────────────
Liệt kê từng FAIL từ Bước 2 và fact-check Bước 3:
[C01] [Section] [Claim sai hoặc thiếu] [Giá trị đúng] [Cách fix]
[C02] ...

───────────────────────────────
NHÓM 3: WARNING (nên fix nhưng không block)
───────────────────────────────
[W01] [Section] [Vấn đề] [Đề xuất cải thiện]
[W02] ...

───────────────────────────────
NHÓM 4: PASSES TỐT (ghi nhận để không vô tình xóa khi fix)
───────────────────────────────
- Những section/component nào làm tốt, đúng spec
- Những insight kỹ thuật nào được giải thích tốt hơn cả spec yêu cầu

═══════════════════════════════════════════════════════════
SAU KHI BÁO CÁO: THỰC HIỆN FIX
═══════════════════════════════════════════════════════════

Thực hiện fix TẤT CẢ lỗi NHÓM 1 và NHÓM 2 ngay lập tức.
NHÓM 3 (WARNING): fix nếu không tốn quá 10 dòng code, skip nếu phức tạp.

Nguyên tắc khi fix:
- Chỉ sửa đúng chỗ bị lỗi, không rewrite section nguyên vẹn
- Với fact-check sai: lấy giá trị CHÍNH XÁC từ source code repo, không đoán
- Với JS function lỗi: test lại bằng cách trace call stack thủ công
- Sau mỗi fix: ghi "[FIXED F01]" vào báo cáo

Sau khi fix xong:
- Báo cáo số dòng trước và sau khi fix
- Liệt kê line number của từng thay đổi
- Xác nhận file mở được trên browser không lỗi console
```

---

> **Lưu ý cho Antigravity:**
> Bước 3 (Fact-check) là bước quan trọng nhất và dễ bỏ sót nhất.
> Claude hay "confabulate" — bịa số liệu hoặc tên hàm trông có vẻ đúng.
> Phải đối chiếu với source code repo line-by-line, không tin vào memory.
