# Master Roadmap: Từ Zero đến Senior Data Engineer

> **Dành cho:** Beginner & Mid-level | **Thời gian:** 6–8 tháng | **Commitment:** 2–3 giờ/ngày

---

## 01 · Big Picture — Data Engineer làm gì?

Hiểu rõ cuộc chơi trước khi bắt đầu. Không lặn ngụp trong tool nếu chưa biết đích đến.

### Định nghĩa ngắn gọn

Data Engineer (DE) là người xây dựng "hệ thống ống nước" (pipelines) để vận chuyển dữ liệu từ nguồn (App, API, DB) về kho lưu trữ tập trung, làm sạch và chuẩn bị sẵn sàng cho Data Analyst, Data Scientist hoặc hệ thống AI sử dụng một cách **đúng, đủ, kịp thời và tối ưu chi phí**.

### Hệ sinh thái & Vị trí 7 Module Zoomcamp

**1. Infrastructure & Orchestration** — Nền tảng hạ tầng và lập lịch tự động.
- **Module 01 (Docker + Terraform):** Đóng gói app, tự động hóa tạo hạ tầng.
- **Module 02 (Kestra/Airflow):** Lập lịch, quản lý luồng chạy, retry khi lỗi.
- **Module 05 (Platform):** Quản lý metadata, assets.

**2. Storage & Transformation** — Nơi dữ liệu hạ cánh và được nhào nặn.
- **Module 03 (BigQuery/DWH):** Lưu trữ khổng lồ, truy vấn siêu tốc.
- **Module 04 (dbt):** Transform raw data thành mô hình chuẩn (Kimball, Medallion).

**3. Heavy Compute (Batch)** — Xử lý dữ liệu định kỳ khối lượng khủng.
- **Module 06 (Spark):** Xử lý dữ liệu phân tán (TB, PB), backfill lịch sử.

**4. Real-time (Streaming)** — Dữ liệu chảy liên tục, xử lý tức thì.
- **Module 07 (Kafka + Flink):** Message broker, xử lý stateful stream, low latency.

---

## 02 · Hệ thống 3 Tầng — Level Learning System

Đừng cố học Senior khi bạn chưa vững Beginner. Đây là cách phân cấp kiến thức để không bị ngợp.

### LEVEL 1 — BEGINNER
**Mục tiêu:** Hiểu cơ bản & Chạy được.
- **Skill:** Setup môi trường, gõ lại tutorial không lỗi.
- **Output:** Script chạy thành công.
- **Sai lầm:** Copy paste mù quáng, không đọc error log.

### LEVEL 2 — INTERMEDIATE
**Mục tiêu:** Độc lập & Build pipeline.
- **Skill:** Tự ghép các module (Zoomcamp level), debug lỗi phổ thông.
- **Output:** Mini project cá nhân.
- **Sai lầm:** Nghĩ "chạy được là xong", bỏ qua xử lý lỗi (exception handling).

### LEVEL 3 — SENIOR
**Mục tiêu:** Production & System Thinking.
- **Skill:** Optimize cost, design architecture, scale, CI/CD, data quality.
- **Output:** Runbook, Architecture docs, PR review.
- **Sai lầm:** Over-engineering, dùng tool khủng cho data nhỏ.

---

## 03 · Cốt lõi phương pháp — Core Learning Flow

Đây là bí quyết để biến tutorial thành kỹ năng thực tế. Bỏ qua một bước là kiến thức sẽ rơi rụng.

**7 bước:** `Read` → `Run` → `Break` → `Debug` → `Explain` → `Improve` → `Document`

| Bước | Làm gì? | Vì sao quan trọng? | Ví dụ |
|---|---|---|---|
| **Read** | Đọc README, lướt source code, tìm entry point. | Nắm bức tranh tổng thể trước khi lạc vào chi tiết code. | Biết file `docker-compose.yml` nằm đâu và có mấy service. |
| **Run** | Chạy script, setup infra theo hướng dẫn chuẩn. | Tạo baseline. Đảm bảo môi trường work đúng. | Chạy lệnh `docker-compose up -d` thành công. |
| **Break** | Cố tình phá hỏng pipeline (tắt DB, đổi port, xóa file). | Hiểu giới hạn hệ thống và cách nó thất bại (fail-fast). | Đổi mật khẩu DB trong `.env` khi pipeline đang chạy. |
| **Debug** | Đọc log, tìm Root Cause, sửa lại cho đúng. | Kỹ năng sống còn. Fix lỗi là lúc não học nhiều nhất. | Mở `docker logs`, search Google mã lỗi, sửa lại `.env`. |
| **Explain** | Tự giải thích lại cơ chế bằng tiếng Việt. | Feynman technique. Chuẩn bị cho phỏng vấn. | "Lỗi connection refused là do service app start trước khi DB ready." |
| **Improve** | Tối ưu code cũ, thêm rule, clean up. | Tư duy refactoring, hướng tới production. | Thêm `depends_on` và `healthcheck` vào compose. |
| **Document** | Ghi chú lại vào Logbook hoặc Markdown. | Xây dựng kho tàng kiến thức cá nhân (Second Brain). | Viết bài blog hoặc note lại trong Github. |

---

## 04 · Thực thi hàng ngày — Daily Execution Plan

Routine 150 phút mỗi ngày. Kỷ luật sinh ra tự do.

### Timebox (150 phút)
- **30m Đọc:** Concepts, tài liệu, diagram.
- **60m Chạy code:** Clone repo, run tutorial, setup.
- **30m Debug/Break:** Áp dụng flow phá lỗi.
- **20m Logbook:** Ghi chép lại lỗi và cách giải quyết.
- **10m Explain:** Trình bày to thành tiếng (giả lập phỏng vấn).

### The Iron Rules
- **Rule 1:** KHÔNG tính thời gian học nếu hôm đó không gõ/chạy dòng code nào.
- **Rule 2:** KHÔNG qua module mới nếu chưa tự tay debug ít nhất 2 lỗi.
- **Rule 3:** KHÔNG copy-paste error vào ChatGPT ngay lập tức. Phải đọc log trước 5 phút.

---

## 05 · Lộ trình cốt lõi — Module Roadmap (01 → 07)

Chiến lược cày từng module theo 3 levels và production patterns.

---

### Module 01 — Docker & Terraform

**Beginner:**
- Hiểu Container vs VM. Hiểu IaC.
- Chạy thành công `docker run` và `terraform apply` basic.

**Intermediate:**
- Đọc hiểu Dockerfile, docker-compose.
- Tự build custom image cho script Python. Tự cấu hình GCP resources qua TF.

**Senior Questions:**
- Fail: Nếu TF apply đứt mạng giữa chừng?
- Scale: Nếu có 50 services, quản lý Compose/K8s sao?
- Cost: Quản lý resource limit trong Docker thế nào?

**Pro-tier patterns:**
Multi-stage builds để giảm image size. Quản lý Terraform remote state bằng GCS backend + State locking. CI/CD cho Terraform (plan on PR, apply on merge). Secret injection thay vì hardcode.

[→ Vào bài học chi tiết Module 01](Module01_Docker_Terraform.html)

---

### Module 02 — Workflow Orchestration

**Beginner:**
- Hiểu DAG, Task, Schedule.
- Chạy được 1 luồng hello-world trên Airflow/Kestra.

**Intermediate:**
- Hiểu Parameterization, Variables.
- Tự build DAG daily ingest API vào DB với retry.

**Senior Questions:**
- Fail: Làm sao chạy lại từ task bị fail mà không duplicate data?
- Scale: Lập lịch 10,000 DAGs, bottleneck ở đâu?
- Alert: Alert SLA trễ như thế nào?

**Pro-tier patterns:**
Tuyệt đối tuân thủ **Idempotency** (chạy N lần kết quả như 1). Dynamic DAG generation. Backfill strategy theo partition date. Cấu hình task timeout và SLA alerts.

[→ Vào bài học chi tiết Module 02](Module02_Orchestration.html)

---

### Module 03 — Data Warehouse (BigQuery)

**Beginner:**
- Hiểu OLAP vs OLTP. Columnar storage.
- Tạo table, query cơ bản trên BQ UI.

**Intermediate:**
- Đọc hiểu External tables, Partition, Cluster.
- Tự design schema cho dataset thực tế, load data từ GCS.

**Senior Questions:**
- Cost: Làm sao giới hạn bytes billed per query?
- Scale: Update/Delete hàng tỷ record trong DWH thế nào?
- Security: Quản lý Row/Column level security?

**Pro-tier patterns:**
Luôn luôn dùng Partitioning (thường theo DATE) và Clustering. Cấm dùng `SELECT *`. Thiết lập Custom Quotas để chống query tỉ đô. Materialized views cho dashboard chậm.

[→ Vào bài học chi tiết Module 03](Module03_Data_Warehouse.html)

---

### Module 04 — Analytics Engineering (dbt)

**Beginner:**
- Hiểu vai trò của dbt (phần T trong ELT).
- Chạy `dbt run` và tạo được view/table đơn giản.

**Intermediate:**
- Hiểu Jinja, Macros, Tests cơ bản.
- Tự build luồng Staging → Mart theo Medallion architecture.

**Senior Questions:**
- Fail: Nếu model chạy fail, downstream model ảnh hưởng sao?
- Cost: Chiến lược Incremental load tối ưu nhất?
- Scale: Quản lý hàng trăm models không bị spaghetti?

**Pro-tier patterns:**
Sử dụng dbt Slim CI (chỉ chạy models bị thay đổi). Áp dụng nghiêm ngặt Data Contracts & Tests (unique, not_null). Tận dụng Packages (dbt-utils, dbt-expectations). Generate và host dbt docs.

[→ Vào bài học chi tiết Module 04](Module04_Analytics_Engineering.html)

---

### Module 05 — Data Platforms (Platform Thinking)

*Module này nâng cấp tư duy từ viết script rải rác sang quản trị Data như một Sản phẩm.*

**Intermediate — Tooling:**
- Sử dụng các tool quản lý asset (ví dụ: Bruin, Dagster).
- Biết khai báo dependencies giữa các data assets.

**Senior — Governance:**
- Tích hợp Data Lineage (trace từ source tới dashboard).
- Định nghĩa Ownership và Data Catalog (DataHub/Amundsen).

[→ Vào bài học chi tiết Module 05](Module05_Data_Platforms.html)

---

### Module 06 — Batch Processing (Spark)

**Beginner:**
- Hiểu Distributed computing, Resilient Distributed Datasets (RDDs), DataFrames.
- Chạy PySpark script đếm dòng cơ bản.

**Intermediate:**
- Đọc hiểu Transformation vs Action, Lazy evaluation.
- Tự viết job xử lý 10GB data, group by và join ghi ra Parquet.

**Senior Questions:**
- Fail: OOM (Out of memory) xử lý sao?
- Perf: Data skew trong lúc join giải quyết thế nào?
- Cost: Chọn Cluster sizing ra sao cho job chạy hàng ngày?

**Pro-tier patterns:**
Tuning memory (Executor, Driver, Overhead). Xử lý Data Skew bằng Salting hoặc AQE. Tránh Shuffle tối đa (dùng Broadcast Hash Join). Quản lý Small Files problem (dùng Coalesce/Repartition hợp lý).

[→ Vào bài học chi tiết Module 06](Module06_Batch_Processing.html)

---

### Module 07 — Streaming (Kafka + Flink)

**Beginner:**
- Hiểu Message Broker, Topic, Publisher, Subscriber.
- Chạy được Kafka local, push/pull message CLI.

**Intermediate:**
- Hiểu Offset, Consumer Group, Partitions.
- Tự build app Python produce JSON và Flink consume tính tổng.

**Senior Questions:**
- Fail: Exactly-once semantics thực hiện thế nào?
- Scale: Lag tăng cao, làm sao scale consumers?
- Data: Xử lý schema evolution (Avro/Protobuf) thế nào?

**Pro-tier patterns:**
Cấu hình Topic Partition strategy dựa trên throughput. Giám sát Consumer Lag chặt chẽ. Xử lý late arriving data bằng Watermarks. Tích hợp Schema Registry để block bad data ngay từ producer.

[→ Vào bài học chi tiết Module 07](Module07_Streaming.html)

---

## 06 · The Masterpiece — Project Xuyên Suốt Thực Chiến

Đừng làm 7 cái project lắt nhắt. Hãy làm 1 cái to, kiến trúc chuẩn, nâng cấp dần.

### Architecture Diagram

```
[Sources]
  ├── Taxi CSVs (Batch)
  ├── Weather API (Batch)
  └── User Clicks (Stream)
       │
[Ingestion & Orchestration - Kestra/Airflow + Docker]
  ├── GCS Landing Zone (Raw)
  └── Kafka Topics (Raw Events)
       │
[Processing - Spark & Flink]
  ├── Spark: Heavy aggregations, Backfills -> GCS/BQ
  └── Flink: Real-time fraud/surge detection -> Alert Webhook
       │
[Warehouse & Transformation - BigQuery & dbt]
  ├── Bronze: Raw tables
  ├── Silver: Cleaned, deduped (dbt)
  └── Gold: Business Marts (dbt)
       │
[Serving & Observability]
  ├── Dashboard (Metabase/Looker Studio)
  └── Data Quality & Alerts (Slack/Email)
```

### Phase 1: Batch Foundation (MVP)
- **Goal:** Xây bộ khung chạy được E2E.
- **Tech:** Docker, Terraform, Kestra, BQ, dbt.
- **Task:** Ingest file Taxi lên GCS → Load vào BQ → dbt transform → Vẽ 1 chart cơ bản.
- **Output:** Repo có IaC, DAG chạy mượt hàng ngày.

### Phase 2: Enrichment & Quality
- **Goal:** Tăng tính thực tế và ổn định.
- **Tech:** Python API, dbt tests.
- **Task:** Kéo Weather API join với Taxi data. Viết tests chặn data null/sai logic. Bật CI/CD.
- **Output:** Pipeline idempotent, có cảnh báo khi API fail hoặc data bẩn.

### Phase 3: Real-time Streaming
- **Goal:** Xử lý dữ liệu nóng.
- **Tech:** Kafka, Flink.
- **Task:** Giả lập stream user click. Flink join stream với static data từ DB, tính surge pricing real-time.
- **Output:** Stream pipeline chạy song song batch, bắn alert Slack khi có anomaly.

---

## 07 · Não bộ Kiến trúc sư — System Design Mini-Case

Cách trả lời phỏng vấn System Design. Vấn đề không nằm ở tool, mà nằm ở Trade-offs.

### Case 1: Hệ thống Batch 1TB/day
- **Problem:** Log file từ web server đẩy về S3 1TB mỗi ngày, cần extract thông tin user tạo báo cáo lúc 8h sáng.
- **Constraint:** Cost phải rẻ, query phải nhanh lúc sáng sớm.
- **Expected Thinking:** Không dump thẳng vào DWH. Dùng Spark xử lý trên EMR/Dataproc, filter rác, nén Parquet/Snappy, partition theo ngày rồi mới load vào BQ/Snowflake. Dùng dbt incremental update mart.
- **Sai lầm phổ biến:** Xài Python thuần đọc 1TB (sập RAM), hoặc load raw text thẳng vào DWH (tiền cloud x10).

### Case 2: Hệ thống Streaming Payment
- **Problem:** Hệ thống thanh toán cần check fraud trong 2 giây.
- **Constraint:** Không được mất event (Zero loss), độ trễ thấp.
- **Expected Thinking:** Kafka với config `acks=all`, replication factor 3. Flink đọc xử lý stateful (windowing). Quan trọng nhất: Design Idempotent consumer để xử lý duplicate (vì at-least-once guarantee).
- **Sai lầm phổ biến:** Bỏ qua xử lý duplicate events, cấu hình Kafka mặc định mất data khi broker sập.

### Case 3: Data Platform Multi-team
- **Problem:** 5 team Data Analyst khác nhau cùng đụng vào DWH, query dẫm chân nhau, schema thay đổi liên tục làm hỏng report.
- **Constraint:** Phải có Governance, không cản trở tốc độ dev.
- **Expected Thinking:** Data Mesh concept. Medallion architecture rõ ràng. Bắt buộc có Data Contracts giữa các layer. Phân quyền RLS/CLS. CI/CD strict cho dbt.
- **Sai lầm phổ biến:** Cấp quyền admin cho mọi người, thiếu lineage, sửa view trực tiếp trên UI thay vì qua code.

---

## 08 · Diễn tập cứu hỏa — Incident Simulation

Senior hơn nhau ở chỗ xử lý sự cố lúc nửa đêm. Hãy diễn tập trước.

| Incident | Symptom (Triệu chứng) | Root Cause & Action | Prevention (Phòng ngừa) |
|---|---|---|---|
| **Pipeline Fail** | DAG đỏ lòm, báo cáo sáng bị rỗng. | <details><summary>Tự nghĩ rồi xem đáp án →</summary>**Cause:** API nguồn đổi cấu trúc json.<br>**Fix:** Sửa parser, backfill lại data từ ngày fail.</details> | <details><summary>Xem đáp án →</summary>Dùng schema registry hoặc validate bằng Data Contracts.</details> |
| **Duplicate Data** | Doanh thu tự nhiên tăng gấp đôi. | <details><summary>Tự nghĩ rồi xem đáp án →</summary>**Cause:** Pipeline chạy retry nhưng lệnh INSERT không xóa data cũ.<br>**Fix:** Chạy query deduplicate, xóa rác.</details> | <details><summary>Xem đáp án →</summary>Biến mọi pipeline thành Idempotent (dùng MERGE/UPSERT thay vì INSERT).</details> |
| **Cost Spike** | Bill GCP tháng này tăng 500%. | <details><summary>Tự nghĩ rồi xem đáp án →</summary>**Cause:** Một Analyst chạy `SELECT *` trên bảng không có partition 100 lần.<br>**Fix:** Kill query, block user tạm thời.</details> | <details><summary>Xem đáp án →</summary>Bắt buộc `require_partition_filter=true`, set custom Quotas.</details> |
| **Kafka Lag** | Dashboard real-time bị delay 30 phút. | <details><summary>Tự nghĩ rồi xem đáp án →</summary>**Cause:** Lưu lượng đột biến (sale event), consumers xử lý không kịp.<br>**Fix:** Scale up consumer group (nếu số partition cho phép).</details> | <details><summary>Xem đáp án →</summary>Monitor offset lag metric, setup auto-scaling rule.</details> |
| **Schema Change** | Cột `price` chuyển từ INT sang STRING, pipeline crash. | <details><summary>Tự nghĩ rồi xem đáp án →</summary>**Cause:** Backend dev sửa DB không báo cáo.<br>**Fix:** Cập nhật dbt cast type, chạy lại pipeline.</details> | <details><summary>Xem đáp án →</summary>Communication quy trình rõ ràng, CI/CD báo lỗi từ vòng staging.</details> |

---

## 09 · Tiền bạc & Tốc độ — Cost & Performance

Kỹ sư xịn không chỉ làm cho nó chạy, mà làm cho nó chạy nhanh và rẻ nhất.

> **The Golden Rule:** Luôn dự toán chi phí trước khi deploy architecture. Luôn Explain Plan trước khi chạy query lớn.

### BigQuery Tuning
- Cost tính theo lượng data scan.
- Giảm cost: Chọn đúng cột, dùng Partition & Cluster.
- Tuyệt đối tránh Cross Join vô ý.

### Spark Tuning
- Kẻ thù số 1 là **Shuffle** (di chuyển data qua mạng).
- Dùng Broadcast Hash Join cho bảng nhỏ.
- Tuning bộ nhớ: Tránh OOM bằng cách chỉnh overhead, chia nhỏ partitions.

### Kafka Throughput
- Speed phụ thuộc Disk I/O và Network.
- Tăng batch size để tăng throughput.
- Số consumers tối đa = Số partitions. Thiết kế partition key cẩn thận tránh skew.

---

## 10 · Lựa chọn vũ khí — Decision Making (Trade-offs)

Công cụ nào cũng có mặt trái. Hiểu khi nào KHÔNG NÊN dùng mới là làm chủ công nghệ.

| Công cụ | Khi NÀO dùng? | Khi nào KHÔNG DÙNG? | Trade-off (Đánh đổi) |
|---|---|---|---|
| **Docker** | Đóng gói service, CI/CD, chạy ở đâu cũng giống nhau. | Chạy 1 script python bé tí dùng 1 lần, resource máy siêu yếu. | Consistency **đổi lấy** Overhead quản lý image/networking. |
| **Airflow/Kestra** | Quản lý chục pipeline phức tạp, phụ thuộc lẫn nhau, cần alert. | 1 task cronjob đơn giản chạy mỗi tháng 1 lần. | Reliability & Observability **đổi lấy** Chi phí vận hành scheduler. |
| **BigQuery** | Data lớn (TB/PB), analytical queries phức tạp. | OLTP transaction (insert/update từng dòng liên tục). | Zero-ops & Scale **đổi lấy** Nguy cơ bill tiền tỉ nếu query ngu. |
| **Spark** | ETL khối lượng dữ liệu khổng lồ vượt quá giới hạn 1 máy. | Data vài trăm MB (hãy dùng Pandas/DuckDB cho nhanh). | Distributed power **đổi lấy** Độ phức tạp setup và debug OOM cực khổ. |
| **Kafka** | Event streaming chịu tải cao, decoupling microservices. | Bắn vài message mỗi phút, không cần real-time (dùng API/DB pull là đủ). | High throughput/Low latency **đổi lấy** Hệ sinh thái nặng nề, khó maintain. |

---

## 11 · Nhật ký chiến đấu — Logbook Template

Đây là bằng chứng duy nhất chứng minh bạn đã thực sự "nhúng chàm". Cứ gặp lỗi là mở file Notion/Markdown ra điền vào.

```markdown
# Logbook Entry: [Tên Lỗi / Vấn đề]
- **Date:** YYYY-MM-DD
- **Module/Task:** Đang làm gì (VD: Setup Terraform GCS)
- **Command executed:** `terraform apply`
- **Expected outcome:** Tạo thành công 1 bucket.
- **Actual error (copy paste):** 
  `Error 403: Caller does not have storage.buckets.create access`
- **Investigation / Root cause:** 
  Tài khoản Service Account đang dùng thiếu role Storage Admin.
- **Fix applied:** 
  Vào IAM GCP, add role `Storage Admin` cho service account, tạo key mới.
- **Lesson Learned:** 
  Luôn check IAM permissions trước khi chạy IaC. Nguyên tắc Least Privilege.
```

---

## 12 · Khi nào là xong? — Definition of Done (DoD)

Tuyệt đối không lướt qua module mới nếu chưa tick đủ các mục này.

- [ ] **Chạy được:** Code/Pipeline chạy thành công từ đầu đến cuối không vấp.
- [ ] **Hiểu được:** Có thể vẽ lại kiến trúc ra giấy trắng mà không nhìn tài liệu.
- [ ] **Phá được:** Đã tự tạo ra ít nhất 1 lỗi và ghi chép lại cách fix vào Logbook.
- [ ] **Tối ưu được:** Code đã được format gọn gàng, chia file hợp lý, không hardcode password.
- [ ] **Trả lời được:** Giải quyết trôi chảy các câu hỏi "Senior Questions" của module đó.

---

## 13 · Kế hoạch 7 Ngày — Execution Plan per Module

Chia nhỏ lịch học 5–7 ngày cho mỗi module để không bị ngợp. Mỗi ngày đều phải có output.

### M01 — Docker & Terraform (7 Days)

| Ngày | Task | Command | Break/Error |
|---|---|---|---|
| D1–D2 | Setup Docker, chạy Postgres + pgAdmin | `docker-compose up -d` | Trùng port 5432, sai biến môi trường. |
| D3–D4 | Dockerize script Python ingest data | `docker build -t ingest .` | Lỗi thiếu dependency trong image, fail connect network. |
| D5–D6 | Viết Terraform tạo GCP Bucket & BQ | `terraform init && apply` | Xóa file tfstate cục bộ, thiếu IAM permissions. |
| D7 | Review & Update Logbook | `git commit -m "M01 done"` | Giải thích flow từ source tới Bucket. |

### M02 — Workflow Orchestration (7 Days)

| Ngày | Task | Command/Action | Break/Error cần thử |
|---|---|---|---|
| D1–D2 | Đọc hiểu Kestra UI, chạy hello-world flow | Mở localhost Kestra, trigger flow thủ công | Sửa sai schedule cron syntax, xem lỗi |
| D3–D4 | Build DAG ingest dữ liệu từ API vào GCS với retry | Viết flow YAML, cấu hình retry + timeout | Tắt kết nối giữa chừng, xem retry có hoạt động không |
| D5–D6 | Thêm idempotency: chạy lại không duplicate data | Dùng MERGE/UPSERT thay INSERT thuần | Chạy flow 2 lần, kiểm tra data có bị nhân đôi không |
| D7 | Thêm SLA alert + viết Logbook | Cấu hình notification khi task trễ | Git commit, ghi lại lỗi đã gặp |

### M06 — Batch Processing / Spark (7 Days)

| Ngày | Task | Command/Action | Break/Error cần thử |
|---|---|---|---|
| D1–D2 | Setup PySpark local, chạy script đếm dòng cơ bản | spark-submit basic_count.py | Đặt sai master URL, thiếu JAVA_HOME |
| D3–D4 | Viết job đọc Parquet, group by, join, ghi ra Parquet | Xử lý NYC Taxi dataset từ repo | Tăng data size, xem OOM xảy ra khi nào |
| D5–D6 | Tối ưu: Broadcast join, repartition, cache | Đo thời gian trước/sau tối ưu | Xóa cache giữa chừng, tạo data skew nhân tạo |
| D7 | Đọc Spark UI, identify bottleneck + Logbook | localhost:4040 khi job đang chạy | So sánh execution plan trước/sau optimize |

### M07 — Streaming / Kafka + Flink (7 Days)

| Ngày | Task | Command/Action | Break/Error cần thử |
|---|---|---|---|
| D1–D2 | Setup Kafka local, produce/consume message qua CLI | kafka-console-producer + consumer | Kill broker giữa chừng, xem message có mất không |
| D3–D4 | Viết Python producer JSON + Flink consumer tính tổng | Chạy producer.py, flink job | Gửi message sai schema, xem consumer xử lý sao |
| D5–D6 | Xử lý duplicate: idempotent consumer + offset commit | Cấu hình enable.auto.commit=false | Crash consumer trước khi commit, đếm duplicate |
| D7 | Monitor consumer lag + Schema Registry cơ bản + Logbook | Dùng kafka-consumer-groups.sh | Tăng tốc độ produce, xem lag tăng thế nào |

*Pattern chung cho M03-M05: 2 ngày theory/setup – 2 ngày hands-on – 2 ngày break/debug – 1 ngày document*

---

## 14 · Độ đo thực tế — Production Metrics

DE không chỉ build pipeline, mà phải giám sát nó bằng các con số (SLI/SLA).

### Data Freshness
- **Định nghĩa:** Dữ liệu có mặt trên dashboard trễ nhất là bao lâu so với thực tế.
- **Ví dụ:** Báo cáo lúc 8h sáng phải có data của 23h59 hôm qua.
- **Cách đo:** So sánh `MAX(created_at)` trong DWH với current_timestamp.

### Latency & Throughput
- **Định nghĩa:** Latency là thời gian xử lý 1 record. Throughput là số records / giây.
- **Ví dụ:** Streaming payment check fraud < 2s (Latency), chịu tải 10,000 TPS (Throughput).
- **Cách đo:** Monitor lag trên Kafka, hoặc thời gian chạy DAG của Airflow.

### Error Rate & SLA
- **Định nghĩa:** Tỉ lệ record bị rớt / tổng số record. SLA là cam kết uptime.
- **Ví dụ:** SLA 99.9% uptime, error rate < 0.01% cho event tracking.
- **Cách đo:** Đếm số lượng record nhảy vào Dead Letter Queue (DLQ).

---

## 15 · Bức tường phòng ngự — Testing & CI/CD

Nếu không có test, pipeline của bạn chỉ là 1 quả bom nổ chậm.

### Flow CI/CD Tiêu Chuẩn

```
Local Push -> GitHub Actions -> 1. Lint Code -> 2. Unit Test -> 3. Integration Test -> 4. Deploy (Staging/Prod)
```

### Unit Test (Mã Nguồn)
- **Mục tiêu:** Test từng function Python/Spark xử lý logic.
- **Công cụ:** `pytest`, mock data nhỏ.

### Data Quality Test
- **Mục tiêu:** Đảm bảo dữ liệu không null, unique, đúng format.
- **Công cụ:** `dbt test`, Great Expectations.

### Integration Test
- **Mục tiêu:** Đảm bảo các component nối với nhau không gãy.
- **Công cụ:** Spin up Testcontainers (Docker) để chạy thử E2E.

---

## 16 · Đấu trường Phỏng vấn — Interview Mapping

Cách biến những gì bạn đã học thành câu trả lời ghi điểm tuyệt đối trong vòng phỏng vấn Technical.

### Cách Kể Project (STAR Framework)
- **Situation:** Team cần báo cáo realtime...
- **Task:** Xây pipeline batch và streaming...
- **Action:** Đã dùng Kafka để ingest, Flink xử lý, xử lý duplicate bằng UPSERT trên BQ...
- **Result:** Giảm data freshness từ 24h xuống 5 phút, cost tăng không đáng kể nhờ cluster partition.

### Mẫu 3 Câu Hỏi Cốt Lõi (Mọi Module)
- **Câu hỏi Design:** "Tại sao chọn X mà không chọn Y?" → Trình bày sự đánh đổi (Trade-off) về cost, setup overhead, latency.
- **Câu hỏi Failure:** "Nếu X chết giữa chừng, data có bị mất hoặc duplicate không?" → Trình bày Idempotency và Checkpointing.
- **Câu hỏi Scale:** "Data tăng gấp 100 lần, pipeline của em sập ở đâu trước?" → Trình bày bottleneck (Memory ở Spark, I/O ở Kafka, hay limits ở BigQuery).

---

## 17 · Kỹ năng Sinh tồn — Learning Strategy

Hành trình dài không tránh khỏi bế tắc. Biết lúc nào cần cố, lúc nào cần buông là chìa khóa.

### Khi Bị Stuck (Bế tắc)
Không ngồi nhìn error quá 2 tiếng. Đứng dậy đi bộ. Search GitHub issues theo exact error log. Đặt câu hỏi trong StackOverflow hoặc Slack cộng đồng với đầy đủ context.

### Khi Nào Nên Nghỉ
Não bạn không học được khi mệt mỏi. Sleep is a feature, not a bug. Nếu fix bug sau 12h đêm không ra, đi ngủ. Sáng dậy thường sẽ nhìn ra ngay lỗi typo ngu ngốc.

### Spaced Repetition
Để không quên kiến thức: Mỗi cuối tuần, đừng code mới, hãy mở lại Logbook đọc lướt 15 phút. Giải thích lại các diagram cho vịt cao su nghe.

---

## 18 · Show off — Xây dựng Portfolio đẳng cấp

Nhà tuyển dụng không có thời gian đọc code của bạn. Họ nhìn README và kiến trúc.

### Bắt buộc phải có
- **GitHub Repo:** Clean structure (có folder src, dags, infra...).
- **README.md chuẩn:** Tóm tắt problem, business value, tech stack.
- **Architecture Diagram:** Sơ đồ rõ ràng (dùng draw.io / excalidraw).
- **Reproducibility:** Hướng dẫn chi tiết cách ai đó clone repo và chạy được ngay.

### Vũ khí bí mật (Ghi điểm tuyệt đối)
- **Demo Video (3–5 phút):** Quay màn hình giải thích luồng data chảy và show dashboard kết quả.
- **Cost Analysis:** Một đoạn phân tích hệ thống này tốn bao nhiêu tiền cloud mỗi tháng.
- **Incident Report:** Kể lại một lỗi khó bạn gặp phải và quá trình suy luận để giải quyết nó.

---

## 19 · Kiểm tra cuối cùng — Final Readiness Checklist

Bạn đang ở level nào? Hãy thành thực với bản thân.

<div style="margin-bottom: 2rem;">
  <div style="display:flex; justify-content:space-between; font-family:monospace; font-size:0.8rem; color:#6b736d; margin-bottom:0.4rem;">
    <span>Tiến độ tự đánh giá</span>
    <span id="checklist-progress-text">0 / 9</span>
  </div>
  <div style="height:3px; background:#2a2e2c; border-radius:2px;">
    <div id="checklist-progress-fill" style="height:100%; width:0%; background:#4ade80; border-radius:2px; transition:width 0.4s ease;"></div>
  </div>
</div>

### Junior
- [ ] Setup được môi trường.
- [ ] Chạy được các tool cơ bản (Docker, SQL).
- [ ] Hiểu ý nghĩa các khái niệm data.

### Mid-Level
- [ ] Tự build end-to-end pipeline.
- [ ] Xử lý lỗi rành rọt, biết đọc log.
- [ ] Sử dụng dbt, Spark, Orchestration trôi chảy.

### Senior
- [ ] Thiết kế hệ thống chịu tải, mở rộng.
- [ ] Đảm bảo Data Quality & Idempotency tuyệt đối.
- [ ] Tối ưu chi phí và hiệu năng hệ thống.

---

## Tóm tắt Lộ trình

1. **Dành cho ai:** Người mới bắt đầu có nền tảng IT cơ bản, hoặc Junior DE muốn nâng trình độ lên hệ thống, chuẩn hóa kỹ năng thực chiến.
2. **Thời gian:** Trung bình 6 đến 8 tháng nếu giữ vững cam kết.
3. **Cách dùng:** Áp dụng *Daily Execution Plan* (150p) mỗi ngày. Kỷ luật ghi chép Logbook. Không học lý thuyết suông, bắt buộc phải Hands-on và Debug.

---

*© 2026 Data Engineering System Architect. Build with passion.*

<script>
  document.querySelectorAll('input[type="checkbox"]').forEach(box => {
    box.addEventListener('click', function() {
      const all = document.querySelectorAll('input[type="checkbox"]').length;
      const checked = document.querySelectorAll('input[type="checkbox"]:checked').length;
      const pct = Math.round(checked / all * 100);
      document.getElementById('checklist-progress-fill').style.width = pct + '%';
      document.getElementById('checklist-progress-text').textContent = checked + ' / ' + all;
    });
  });
</script>
