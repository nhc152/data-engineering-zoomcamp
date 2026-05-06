# Báo cáo Phân tích Repository: Module 01 - Docker & Terraform

Dưới đây là ghi chú tổng hợp về module 01 của khóa Data Engineering Zoomcamp, phân tích về cấu trúc, chức năng, luồng dữ liệu, các design pattern được áp dụng, và các điểm cần cải thiện.

## 1. Cấu trúc thư mục đầy đủ (Tree)

```text
01-docker-terraform/
├── README.md
├── docker-sql/
│   ├── README.md
│   ├── 01-introduction.md
│   ├── 02-virtual-environment.md
│   ├── 03-dockerizing-pipeline.md
│   ├── 04-postgres-docker.md
│   ├── 05-data-ingestion.md
│   ├── 06-ingestion-script.md
│   ├── 07-pgadmin.md
│   ├── 08-dockerizing-ingestion.md
│   ├── 09-docker-compose.md
│   ├── 10-sql-refresher.md
│   ├── 11-cleanup.md
│   └── pipeline/
│       ├── .python-version
│       ├── pyproject.toml
│       ├── uv.lock
│       ├── ingest_data.py
│       ├── Dockerfile
│       ├── docker-compose.yaml
│       └── docker-helper-scripts/
│           ├── docker-postgres.sh
│           ├── docker-pgadmin.sh
│           └── docker-ingest.sh
└── terraform/
    ├── README.md
    ├── 1_terraform_overview.md
    ├── 2_gcp_overview.md
    ├── windows.md
    └── terraform/
        ├── README.md
        ├── terraform_basic/
        │   └── main.tf
        ├── terraform_with_variables/
        │   ├── main.tf
        │   └── variables.tf
        └── terraform_with_variable_AWS/
            ├── main.tf
            ├── variables.tf
            └── terraform.tfvars
```

---

## 2. Các file quan trọng nhất

### `docker-sql/pipeline/ingest_data.py`
- **Mục đích**: Ingest (nạp) dữ liệu từ file CSV nén trên Internet vào cơ sở dữ liệu PostgreSQL.
- **Nội dung cốt lõi**:
  - Dùng `click` để nhận các tham số dòng lệnh (credentials, host, port, table_name, year, month...).
  - Kết nối DB qua `sqlalchemy` (`postgresql+psycopg`).
  - Định nghĩa sẵn `dtype` chuẩn cho các trường dữ liệu và xác định các cột cần parse datetime (`parse_dates`).
  - Đọc CSV file theo từng block (chunks) nhờ tham số `iterator=True` và `chunksize` của thư viện `pandas`.
  - Lặp qua từng chunk (có hiển thị tiến trình bằng `tqdm`), chunk đầu sử dụng `if_exists='replace'` để định nghĩa lược đồ (schema) và bảng mới, các chunk tiếp theo dùng `if_exists='append'`.
- **Điểm đặc biệt đáng chú ý**: Sử dụng cơ chế chunking giúp script có khả năng nạp dữ liệu lớn hơn nhiều so với dung lượng RAM khả dụng.

### `docker-sql/pipeline/Dockerfile`
- **Mục đích**: Container hóa môi trường Python và kịch bản `ingest_data.py`.
- **Nội dung cốt lõi**:
  - Base image nhẹ: `python:3.13.11-slim`.
  - Copy công cụ quản lý package siêu tốc `uv` từ `ghcr.io/astral-sh/uv` theo kiểu multi-stage build.
  - Thiết lập thư mục làm việc, cài đặt dependencies nghiêm ngặt theo `pyproject.toml` và file lock thông qua lệnh `uv sync --locked`.
  - `ENTRYPOINT` để tự động chạy `python ingest_data.py`.
- **Điểm đặc biệt đáng chú ý**: Triển khai `uv` cực kì hiện đại, thay thế hoàn toàn `pip` và `requirements.txt` cổ điển, tối ưu hóa quá trình caching layer trong Docker.

### `docker-sql/pipeline/docker-compose.yaml`
- **Mục đích**: Quản lý infrastructure (hạ tầng cơ sở dữ liệu cục bộ) bằng một công cụ orchestration đơn giản.
- **Nội dung cốt lõi**:
  - Cấu hình 2 service: `pgdatabase` (Postgres 18) và `pgadmin` (giao diện quản trị web).
  - Trỏ các port ra máy host (5432 và 8085).
  - Khai báo và ánh xạ các named volumes (`ny_taxi_postgres_data` và `pgadmin_data`).
- **Điểm đặc biệt đáng chú ý**: Dữ liệu và cấu hình UI được đảm bảo tính persistent qua volumes, không bị bay mất khi reset container. Tự động gom các service chung một local network ẩn.

### `terraform/terraform/terraform_with_variables/main.tf`
- **Mục đích**: Provision (cấp phát) hạ tầng đám mây trên nền tảng Google Cloud (GCP) tự động.
- **Nội dung cốt lõi**:
  - Gọi Provider `google`.
  - Cấp phát 1 bucket trên Google Cloud Storage làm Data Lake. Có gắn policy `lifecycle_rule` tự động dọn dẹp các mảnh vụn upload chưa hoàn chỉnh.
  - Cấp phát 1 Dataset trống trên BigQuery để làm Data Warehouse.
- **Điểm đặc biệt đáng chú ý**: Chuyển biến số sang `variables.tf`, giúp tái sử dụng và dễ thay thế.

### `terraform/terraform/terraform_with_variable_AWS/main.tf`
- **Mục đích**: Phiên bản provision hạ tầng tương tự nhưng dành cho AWS.
- **Nội dung cốt lõi**:
  - Cấp phát `aws_s3_bucket`, đi kèm với Versioning, chặn truy cập Public, thiết lập Lifecycle rule xóa object cũ hơn 30 ngày.
  - Cấp phát `aws_glue_catalog_database` tương ứng làm Data Warehouse logical layer.

---

## 3. Data Flow Thực tế (Module 01)

1. **Nguồn Dữ Liệu (Source)**: Bắt đầu từ file `.csv.gz` của Yellow Taxi được host public trên thư mục Release của repo GitHub `DataTalksClub/nyc-tlc-data`.
2. **Kênh Chuyển & Xử Lý (Processing / Ingestion)**: Dữ liệu chảy qua internet vào bộ nhớ RAM của Docker Container `taxi_ingest`. Tại đây, `pandas` cắt dòng dữ liệu thành các tệp khối (chunks 100k dòng), xử lý đồng nhất kiểu dữ liệu (casting data types) và chuẩn hóa kiểu ngày tháng.
3. **Đích Đến Tạm Thời (Local Storage)**: Mỗi chunk được nạp trực tiếp vào bảng `yellow_taxi_data` trong PostgreSQL Container (thông qua engine của SQLAlchemy). Tại bước này dữ liệu có thể được truy vấn bằng pgAdmin/pgcli để thực hành SQL.
4. **Đích Đến Trên Cloud (IaC setup)**: Terraform thực hiện mở đường bằng cách xây dựng sẵn các hạ tầng trống trên Cloud (GCS/BigQuery hoặc S3/Glue). Việc đẩy dữ liệu lên môi trường đám mây sẽ nằm ở các pipeline module kế tiếp.

---

## 4. Các Pattern được dùng trong code

- **Bounded-Memory / Chunking Pattern**: Sử dụng `pandas.read_csv` với mode `iterator=True` cho phép pipeline có thể ingest file vài chục GB trong một container chỉ có vài trăm MB RAM.
- **Modern Package Management Pattern**: Sử dụng chuẩn `pyproject.toml` và tool `uv` để tạo reproducible builds, tách bạch rõ ràng dependencies của Production (pandas, sqlalchemy) và Dev (jupyter, pgcli).
- **IaC Modularization**: Tách rời tệp Terraform thành `.tf` (định nghĩa resource), `variables.tf` (định nghĩa biến), `terraform.tfvars` (giá trị thực của biến).
- **Container Isolation & Networking**: Ingestion code được đóng gói độc lập. Các module tương tác với nhau không thông qua `localhost` tĩnh, mà bằng DNS nội bộ của Docker Network (gọi thẳng host là `pgdatabase`).
- **Stateless Containers + Stateful Volumes**: Mọi thiết lập cơ sở dữ liệu có thể xóa nóng (Stateless DB Image), nhưng dữ liệu nằm trong Named Volumes nên an toàn sinh tồn qua các chu kỳ phá hủy container.

---

## 5. Điểm yếu hoặc TODO còn trong repo

1. **Hardcoded Secrets (Lộ lọt thông tin)**: Từ `docker-compose.yaml`, các file bash scripts tới `ingest_data.py` đều có các cấu hình tài khoản bị fix cứng (ví dụ `root`:`root`, `admin@admin.com`).
   - *=> Cần refactor để sử dụng file `.env` hoặc cơ chế tiêm Environment Variables.*
2. **Lack of Idempotency (Rủi ro nạp trùng)**: Trong code `ingest_data.py`, script chạy theo kiểu nhồi liên tục (`if_exists='append'`). Nếu mạng lỗi rớt giữa chừng ở chunk số 5, chạy lại script từ đầu sẽ gây đúp dữ liệu ở 4 chunk đầu.
   - *=> Cần cơ chế tracking chunk (watermark), hoặc upserting, hoặc truncate before load trong quá trình phát triển.*
3. **Thiếu Error Handling**: Script Python hoàn toàn không dùng block `try-except`. Nếu URL tải file bị hỏng hoặc kết nối Database chết, pipeline sẽ dump stacktrace thẳng ra console và dừng khẩn cấp.
4. **Phân rã Orchestration chưa tối ưu**: `docker-compose` hiện chỉ chạy DB và UI, còn job nạp data phải tự gõ lệnh build/run bằng terminal (hoặc qua script `.sh` thô sơ).
   - *=> Lí tưởng nhất là đưa luôn service `taxi_ingest` vào `docker-compose.yaml` dưới dạng một service "profiles" hoặc "depends_on" condition.*
5. **Hardcode Schema Types**: Nếu CSV thay đổi tên cột hoặc kiểu dữ liệu ở tháng sau, code `ingest_data.py` sẽ chết do dictionary `dtype` bị fix cứng vào code.
6. **Terraform Local State**: Terraform state vẫn đang được lưu ở dạng file local `.tfstate`, không phù hợp nếu làm việc đội nhóm (nên cấu hình remote backend như GCS/S3).
