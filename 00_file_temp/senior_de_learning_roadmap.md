# Lộ Trình Đào Tạo Senior Data Engineer (Dựa trên DE Zoomcamp)

Dựa vào mã nguồn của khóa học, chúng ta có tổng cộng **7 Module chính, 1 Workshop và 1 Final Project**. Lộ trình dưới đây không chỉ bám sát kiến thức từ repo mà còn bổ sung các **"Pro-tier patterns" (Tiêu chuẩn Senior/Production-ready)** để giúp bạn thăng tiến chuyên sâu.

---

## 🏗️ Module 1: Containerization & Infrastructure as Code (IaC)
**Kiến thức từ Zoomcamp:**
* Giới thiệu Google Cloud Platform (GCP).
* Docker & Docker-Compose cơ bản (chạy PostgreSQL, pgAdmin).
* Khởi tạo hạ tầng với Terraform (tạo Cloud Storage, BigQuery).

**🚀 Nâng cấp Senior Level:**
* **Bảo mật & Tối ưu:** Multi-stage builds cho Docker image, tối ưu dung lượng image, quản lý secrets.
* **Terraform Chuyên sâu:** Quản lý State với Remote Backend (GCS/S3), State Locking, chia nhỏ Terraform thành các Module (DRY), quản lý biến (Variables/Locals).
* **CI/CD cho IaC:** Tự động hóa việc `terraform plan` và `terraform apply` qua GitHub Actions.

---

## ⚙️ Module 2: Workflow Orchestration
**Kiến thức từ Zoomcamp:**
* Khái niệm Data Lake.
* Lập lịch và điều phối quy trình bằng **Kestra** (hoặc Airflow/Prefect/Mage).

**🚀 Nâng cấp Senior Level:**
* **Idempotency:** Thiết kế DAG sao cho chạy lại 100 lần kết quả vẫn đúng, không sinh dữ liệu rác.
* **Backfilling & Catchup:** Chiến lược chạy lại dữ liệu của các tháng/năm trước mà không làm sập hệ thống.
* **Dynamic DAGs:** Tự động sinh DAG từ file cấu hình (YAML/JSON).
* **Observability:** Thiết lập SLAs (Service Level Agreements), Alerts (Slack/Email) khi pipeline thất bại hoặc chạy quá chậm.

---

## 🛠️ Workshop 1: Data Ingestion chuyên sâu
**Kiến thức từ Zoomcamp:**
* Sử dụng thư viện `dlt` (Data Load Tool) để trích xuất dữ liệu từ API.
* Normalization dữ liệu JSON phức tạp.

**🚀 Nâng cấp Senior Level:**
* Xử lý Incremental Load chuyên sâu: Change Data Capture (CDC) vs. Update-timestamp based.
* Rate limiting & API Pagination handling: Cách retry tự động khi API bị quá tải (Exponential backoff).
* Data Contracts cơ bản lúc trích xuất dữ liệu.

---

## 📊 Module 3: Data Warehousing
**Kiến thức từ Zoomcamp:**
* Kiến trúc Google BigQuery.
* Kỹ thuật Partitioning và Clustering.
* Tích hợp Machine Learning ngay trên BigQuery (BQML).

**🚀 Nâng cấp Senior Level:**
* **Query Cost Optimization:** Các lỗi thường gặp gây tốn tiền (Full table scan) và cách tối ưu.
* **Thiết kế Data Modeling:** Phân biệt và ứng dụng Dimensional Modeling (Kimball - Star/Snowflake schema).
* Quản trị quyền truy cập: Row-level security (RLS) và Column-level security (CLS).
* Sử dụng Materialized Views để tăng tốc dashboard.

---

## 🧩 Module 4: Analytics Engineering
**Kiến thức từ Zoomcamp:**
* Sử dụng **dbt (data build tool)** kết nối với BigQuery/DuckDB.
* Viết Test, Document và triển khai model.

**🚀 Nâng cấp Senior Level:**
* **Slim CI:** Chỉ chạy và test những model bị ảnh hưởng trong Pull Request thay vì chạy lại toàn bộ.
* **Advanced Materializations:** Xử lý các cạm bẫy của Incremental model (Merge vs Append).
* **dbt Macros & Packages:** Quản lý package, viết macro để code SQL tái sử dụng.
* **Data Quality Gates:** Cảnh báo dữ liệu sai lệch (Anomaly detection).

---

## 🚀 Module 5: Data Platforms (End-to-End)
**Kiến thức từ Zoomcamp:**
* Xây dựng pipeline end-to-end hoàn chỉnh với **Bruin**.
* Tích hợp từ Ingestion -> Transformation -> Quality.

**🚀 Nâng cấp Senior Level:**
* Đánh giá kiến trúc nền tảng dữ liệu (Modern Data Stack).
* Quản lý Meta-data và Data Lineage (Truy xuất nguồn gốc dữ liệu).

---

## 🐘 Module 6: Batch Processing (Apache Spark)
**Kiến thức từ Zoomcamp:**
* Kiến trúc Spark.
* Spark DataFrames, SQL.
* Cơ chế hoạt động của GroupBy, Joins.

**🚀 Nâng cấp Senior Level:**
* **Performance Tuning:** Tinh chỉnh bộ nhớ (Memory tuning), xử lý Spill to disk.
* **Data Skew:** Cách nhận biết và xử lý dữ liệu bị lệch (Salting, Broadcast Joins).
* **Adaptive Query Execution (AQE):** Tối ưu hóa truy vấn động.
* **Testing:** Hướng dẫn viết Unit Test cho logic Spark (Pytest, chispa).

---

## ⚡ Module 7: Streaming
**Kiến thức từ Zoomcamp:**
* Giới thiệu **Apache Kafka**.
* Xử lý stream với Kafka Streams & KSQL.
* Quản lý Schema với Avro.

**🚀 Nâng cấp Senior Level:**
* **Exactly-Once Semantics (EOS):** Đảm bảo dữ liệu không bị lặp hay mất mát trong quá trình stream.
* **Partition Strategy:** Mở rộng hệ thống Kafka (Scaling consumers, rebalancing).
* **Schema Evolution:** Xử lý sự cố khi cấu trúc dữ liệu từ nguồn thay đổi (Forward/Backward compatibility).
* Khắc phục độ trễ (Consumer Lag monitoring).

---

## 🏆 Final Project (Thực chiến tổng hợp)
**Mục tiêu:** Áp dụng toàn bộ kiến thức để thiết kế một hệ thống Data Engineering chuẩn Production, có đầy đủ các yếu tố:
1. IaC (Terraform)
2. Orchestration & Ingestion (Kestra/Airflow)
3. DWH (BigQuery) & Transformation (dbt)
4. Dashboard (Looker Studio / Metabase)
5. **CI/CD, Alerting, Testing (Tiêu chuẩn Senior)**.
