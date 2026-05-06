# Ghi chú Module 01: Docker & Terraform

═══════════════════════════════
1. CẤU TRÚC THƯ MỤC
═══════════════════════════════

```text
01-docker-terraform/
├── README.md                           # Trang chủ module 01, chứa danh sách links video, hướng dẫn bài tập và notes từ community.
├── docker-sql/                         # Thư mục chứa tài liệu và source code về Docker, Postgres, và Data Ingestion.
│   ├── README.md                       # Mục lục các bài học trong phần Docker & PostgreSQL.
│   ├── 01-introduction.md              # Giới thiệu Docker, tại sao dùng Docker và các lệnh cơ bản.
│   ├── 02-virtual-environment.md       # Cài đặt môi trường ảo Python với `uv`.
│   ├── 03-dockerizing-pipeline.md      # Tạo Dockerfile đơn giản để chạy script python.
│   ├── 04-postgres-docker.md           # Hướng dẫn chạy PostgreSQL trong container với named volumes.
│   ├── 05-data-ingestion.md            # Khám phá dataset NYC Taxi bằng Jupyter Notebook và Pandas.
│   ├── 06-ingestion-script.md          # Chuyển đổi Notebook thành Python script dùng `click`.
│   ├── 07-pgadmin.md                   # Chạy pgAdmin container và kết nối cùng network với PostgreSQL.
│   ├── 08-dockerizing-ingestion.md     # Đóng gói Python script thành Docker image và chạy trên network.
│   ├── 09-docker-compose.md            # Sử dụng docker-compose để chạy đồng thời Postgres và pgAdmin.
│   ├── 10-sql-refresher.md             # Ôn tập SQL: JOINs, Data Quality Checks, GROUP BY, ORDER BY.
│   ├── 11-cleanup.md                   # Xóa container, image, network và volume để dọn dẹp.
│   └── pipeline/                       # Thư mục chứa code thực hành Docker & Python Ingestion.
│       ├── .python-version             # Chứa version Python (3.13) dùng cho tool uv.
│       ├── pyproject.toml              # Cấu hình project và dependencies cho uv (thay thế requirements.txt).
│       ├── ingest_data.py              # Script nạp dữ liệu từ CSV vào PostgreSQL.
│       ├── Dockerfile                  # Dockerfile dùng để container hóa ingest_data.py với base image là python:3.13.11-slim.
│       ├── docker-compose.yaml         # Cấu hình docker-compose chạy pgdatabase và pgadmin.
│       └── docker-helper-scripts/      # Thư mục chứa các shell script hỗ trợ chạy lệnh Docker dài.
│           ├── docker-postgres.sh      # Bash script để chạy Postgres container.
│           ├── docker-pgadmin.sh       # Bash script để chạy pgAdmin container.
│           └── docker-ingest.sh        # Bash script để chạy Ingestion container.
└── terraform/                          # Thư mục chứa tài liệu và code về Terraform & GCP.
    ├── README.md                       # Hướng dẫn cài đặt local cho Terraform và GCP, và cách thực thi.
    ├── 1_terraform_overview.md         # Giới thiệu khái niệm Terraform (IaC), các file cấu hình, lệnh thực thi.
    ├── 2_gcp_overview.md               # Giới thiệu GCP, các module infra (GCS, BigQuery) và setup IAM / SDK.
    ├── windows.md                      # Hướng dẫn cài đặt GCP SDK và Terraform cụ thể trên Windows.
    └── terraform/                      # Thư mục chứa code thực hành Terraform.
        ├── README.md                   # Hướng dẫn chạy các lệnh Terraform và fallback khi lỗi IAM.
        ├── terraform_basic/            # Code Terraform cơ bản dồn vào một file.
        │   └── main.tf                 # File cấu hình Terraform cơ bản tạo Bucket và Dataset.
        ├── terraform_with_variables/   # Code Terraform chia tách biến.
        │   ├── main.tf                 # File cấu hình Terraform tạo Bucket và Dataset gọi từ biến.
        │   └── variables.tf            # File định nghĩa biến (credentials, project, region, bucket_name...).
        └── terraform_with_variable_AWS/# Code Terraform quy đổi sang AWS.
            ├── main.tf                 # File cấu hình Terraform tạo S3 Bucket và Glue Database.
            ├── variables.tf            # File định nghĩa biến AWS (region, bucket_name, dataset_name).
            ├── terraform.tfvars        # File gán giá trị cụ thể cho biến AWS.
            └── README.md               # Giải thích mapping giữa GCP và AWS.
```

═══════════════════════════════
2. NỘI DUNG CÁC FILE .MD
═══════════════════════════════

[docker-sql/README.md]
- Dạy về: Mục lục tổng quan phần Docker và PostgreSQL
- Concepts chính: Data Engineering fundamentals, prerequisite tools.
- Commands được dùng: (Không có)
- Lưu ý đặc biệt: Cung cấp outline 11 bài học chi tiết.

[01-introduction.md]
- Dạy về: Giới thiệu Docker và các lệnh thao tác cơ bản.
- Concepts chính: Containerization, image, statelessness, volumes (bind mounts).
- Commands được dùng: 
  `docker --version`, `docker run hello-world`, `docker run ubuntu`, `docker run -it ubuntu`, `apt update && apt install python3`, `docker ps -a`, `docker rm $(docker ps -aq)`, `docker run -it --rm ubuntu`, `docker run -it --rm python:3.9.16`, `docker run -it --rm --entrypoint=bash python:3.9.16-slim`, `docker run -it --rm -v $(pwd)/test:/app/test --entrypoint=bash python:3.9.16-slim`.
- Lưu ý đặc biệt: Nhấn mạnh tính stateless của container và cách dùng `--rm` để dọn dẹp.

[02-virtual-environment.md]
- Dạy về: Setup môi trường ảo Python và tạo script pipeline cơ bản.
- Concepts chính: Data pipeline architecture, virtual environments, modern package manager (`uv`).
- Commands được dùng: 
  `pip install pandas pyarrow`, `pip install uv`, `uv init --python=3.13`, `uv run which python`, `uv add pandas pyarrow`, `uv run python pipeline.py 10`.
- Lưu ý đặc biệt: Khóa học chuyển sang dùng `uv` làm package manager thay cho `pip` thông thường.

[03-dockerizing-pipeline.md]
- Dạy về: Containerize pipeline script.
- Concepts chính: Viết Dockerfile, building image, multi-stage builds.
- Commands được dùng: 
  `docker build -t test:pandas .`, `docker run -it test:pandas some_number`.
- Lưu ý đặc biệt: Có giới thiệu 2 phiên bản Dockerfile: 1 dùng `pip` và 1 dùng `uv` với `--locked`.

[04-postgres-docker.md]
- Dạy về: Chạy PostgreSQL trong container và kết nối.
- Concepts chính: Environment variables, Named Volumes, Bind Mounts, Port mapping.
- Commands được dùng: 
  `docker run -it --rm -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v ny_taxi_postgres_data:/var/lib/postgresql -p 5432:5432 postgres:18`, `mkdir ny_taxi_postgres_data`, `uv add --dev pgcli`, `uv run pgcli -h localhost -p 5432 -u root -d ny_taxi`, `\dt`, `CREATE TABLE test (id INTEGER, name VARCHAR(50));`, `INSERT INTO test VALUES (1, 'Hello Docker');`, `SELECT * FROM test;`, `\q`.
- Lưu ý đặc biệt: Phân biệt rõ Named Volume (do Docker quản lý) và Bind Mount (map đường dẫn tuyệt đối ở host).

[05-data-ingestion.md]
- Dạy về: Khám phá dataset và nạp dữ liệu bằng Jupyter Notebook.
- Concepts chính: Pandas DataFrames, handling mixed data types, SQLAlchemy, SQL schema generation, Data batching/chunking.
- Commands được dùng: 
  `uv add --dev jupyter`, `uv run jupyter notebook`, `uv add sqlalchemy "psycopg[binary,pool]"`, `uv add tqdm`, `uv run pgcli -h localhost -p 5432 -u root -d ny_taxi`.
- Lưu ý đặc biệt: Xử lý file CSV lớn bằng `iterator=True` và `chunksize=100000`. Sử dụng `if_exists="replace"` cho chunk đầu và `"append"` cho chunk sau.

[06-ingestion-script.md]
- Dạy về: Chuyển Notebook sang script Python và sử dụng CLI arguments.
- Concepts chính: Command-line Interfaces với `click`.
- Commands được dùng: 
  `uv run jupyter nbconvert --to=script notebook.ipynb`, `mv notebook.py ingest_data.py`, `uv run python ingest_data.py --pg-user=root --pg-pass=root --pg-host=localhost --pg-port=5432 --pg-db=ny_taxi --target-table=yellow_taxi_trips`.
- Lưu ý đặc biệt: Script hoàn chỉnh được tổ chức tham số qua decorator của thư viện `click`.

[07-pgadmin.md]
- Dạy về: Cài đặt và sử dụng pgAdmin qua Docker.
- Concepts chính: Docker Networks, container-to-container communication.
- Commands được dùng: 
  `docker run -it -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" -e PGADMIN_DEFAULT_PASSWORD="root" -v pgadmin_data:/var/lib/pgadmin -p 8085:80 dpage/pgadmin4`, `docker network create pg-network`, chạy lại postgres và pgadmin với `--network=pg-network` và `--name`.
- Lưu ý đặc biệt: Nhấn mạnh việc các container phải chung network và gọi nhau bằng `--name` (ví dụ: `pgdatabase`).

[08-dockerizing-ingestion.md]
- Dạy về: Containerize script Ingestion vừa tạo.
- Concepts chính: Build Docker image từ `pyproject.toml`, Docker Network injection.
- Commands được dùng: 
  `docker build -t taxi_ingest:v001 .`, `docker run -it --network=pg-network taxi_ingest:v001 --pg-user=root --pg-pass=root --pg-host=pgdatabase --pg-port=5432 --pg-db=ny_taxi --target-table=yellow_taxi_trips`.
- Lưu ý đặc biệt: `--pg-host` bây giờ không phải `localhost` mà là `pgdatabase` (tên container).

[09-docker-compose.md]
- Dạy về: Orchestration cơ bản bằng Docker Compose.
- Concepts chính: YAML format, services declaration, automatic networking, background mode.
- Commands được dùng: 
  `docker-compose up`, `docker-compose up -d`, `docker-compose down`, `docker-compose logs`, `docker-compose down -v`, `docker network ls`, `docker run -it --rm --network=pipeline_default taxi_ingest:v001...`.
- Lưu ý đặc biệt: Chỉ ra sự tiện lợi khi thay thế chuỗi lệnh bash dài bằng một file cấu hình duy nhất. Tuy nhiên, nó không nhúng container ingest vào file compose.

[10-sql-refresher.md]
- Dạy về: Ôn tập SQL qua dataset Taxi.
- Concepts chính: Implicit/Explicit INNER JOIN, LEFT/RIGHT/OUTER JOINs, Data Quality Checks (IS NULL, NOT IN), GROUP BY, ORDER BY, Aggregations (COUNT, MAX).
- Commands được dùng: Các lệnh SQL querying (SELECT, JOIN, WHERE, GROUP BY, ORDER BY...).
- Lưu ý đặc biệt: Trực tiếp thao tác SQL queries trên pgAdmin thay vì script.

[11-cleanup.md]
- Dạy về: Dọn dẹp tài nguyên Docker và local.
- Concepts chính: Docker resource management (pruning).
- Commands được dùng: 
  `docker-compose down`, `docker ps -a`, `docker rm <container_id>`, `docker container prune`, `docker images`, `docker rmi taxi_ingest:v001`, `docker image prune -a`, `docker volume ls`, `docker volume rm ny_taxi_postgres_data`, `docker volume prune`, `docker network ls`, `docker network rm pg-network`, `docker network prune`, `docker system prune -a --volumes`, `rm *.parquet`, `rm -rf __pycache__ .pytest_cache`, `rm -rf .venv`.
- Lưu ý đặc biệt: Dùng cẩn thận lệnh `docker system prune -a --volumes`.

[terraform/README.md]
- Dạy về: Các bước thực thi Terraform cơ bản và xử lý lỗi IAM (Fallback).
- Concepts chính: Application Default Credentials (ADC), Terraform Init/Plan/Apply/Destroy, Impersonation.
- Commands được dùng: 
  `gcloud auth application-default login`, `terraform init`, `terraform plan -var="project=<your-gcp-project-id>"`, `terraform apply -var="project=<your-gcp-project-id>"`, `terraform destroy`, `gcloud iam service-accounts add-iam-policy-binding...`.
- Lưu ý đặc biệt: Cung cấp giải pháp dùng `google_service_account_access_token` nếu không tải được service account key.

[terraform/1_terraform_overview.md]
- Dạy về: Khái niệm IaC và Terraform cơ bản.
- Concepts chính: Providers, Resources, Variables, Backend, State, Execution Steps.
- Commands được dùng: 
  `terraform init`, `terraform plan`, `terraform apply`, `terraform destroy`.
- Lưu ý đặc biệt: Nêu vai trò quan trọng của file `.tfstate` và các blocks khai báo `terraform`, `provider`, `resource`.

[terraform/2_gcp_overview.md]
- Dạy về: GCP Account setup và IAM.
- Concepts chính: Service Accounts, IAM Roles, Google Cloud SDK, Environment Variables.
- Commands được dùng: 
  `export GOOGLE_APPLICATION_CREDENTIALS="<path/to/your/service-account-authkeys>.json"`, `gcloud auth application-default login`.
- Lưu ý đặc biệt: Phải gán đúng roles: Storage Admin, Storage Object Admin, BigQuery Admin.

[terraform/windows.md]
- Dạy về: Setup GCP SDK và Terraform trên Plain Windows.
- Concepts chính: PATH configuration, Windows Authentication.
- Commands được dùng: 
  `export CLOUDSDK_PYTHON=~/Anaconda3/python`, `gcloud version`, `export GOOGLE_APPLICATION_CREDENTIALS=...`, `gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS`, `gcloud auth application-default login`, `gcloud auth application-default set-quota-project ${PROJECT_NAME}`, `terraform init`.
- Lưu ý đặc biệt: Cách fix lỗi "quota exceeded" bằng `set-quota-project`.

[terraform/terraform/terraform_with_variable_AWS/README.md]
- Dạy về: Cấu trúc hạ tầng ánh xạ từ GCP sang AWS.
- Concepts chính: AWS S3 (thay cho GCS), AWS Glue Data Catalog (thay cho BigQuery).
- Commands được dùng: (Không có)
- Lưu ý đặc biệt: Hỗ trợ các học viên muốn thực hành khóa học bằng AWS.

═══════════════════════════════
3. PHÂN TÍCH CODE FILES
═══════════════════════════════

[docker-compose.yaml]
- Services: 
  - `pgdatabase`: image `postgres:18`, ports `5432:5432`, volumes `ny_taxi_postgres_data:/var/lib/postgresql`, env vars `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
  - `pgadmin`: image `dpage/pgadmin4`, ports `8085:80`, volumes `pgadmin_data:/var/lib/pgadmin`, env vars `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`.
```yaml
services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: "root"
      POSTGRES_PASSWORD: "root"
      POSTGRES_DB: "ny_taxi"
    volumes:
      - ny_taxi_postgres_data:/var/lib/postgresql
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "admin@admin.com"
      PGADMIN_DEFAULT_PASSWORD: "root"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    ports:
      - "8085:80"



volumes:
  ny_taxi_postgres_data:
  pgadmin_data:
```

[Dockerfile]
- Base image: `python:3.13.11-slim`
- Layers: COPY uv binary -> Thiết lập WORKDIR và ENV PATH -> COPY pyproject.toml, .python-version, uv.lock -> RUN uv sync --locked -> COPY ingest_data.py
- Entry point: `["python", "ingest_data.py"]`
```dockerfile
FROM python:3.13.11-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"

COPY pyproject.toml .python-version uv.lock ./
RUN uv sync --locked

COPY ingest_data.py .

ENTRYPOINT ["python", "ingest_data.py"]
```

[ingest_data.py]
- Arguments nhận vào: `--pg-user`, `--pg-pass`, `--pg-host`, `--pg-port`, `--pg-db`, `--year`, `--month`, `--target-table`, `--chunksize`
- Logic chính: 
  1. Tạo URL download file CSV dựa trên biến year/month.
  2. Tạo engine SQLAlchemy kết nối Postgres.
  3. Dùng pandas đọc file CSV dưới dạng chunk iterator.
  4. Lặp qua các chunks (dùng tqdm để show progress bar): chunk đầu tiên tạo bảng (`if_exists='replace'`), các chunk sau chèn thêm dữ liệu (`if_exists='append'`).
- Libraries dùng: `click`, `pandas`, `sqlalchemy`, `tqdm.auto`.
```python
#!/usr/bin/env python
# coding: utf-8

import click
import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]


@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--year', default=2021, type=int, help='Year of the data')
@click.option('--month', default=1, type=int, help='Month of the data')
@click.option('--target-table', default='yellow_taxi_data', help='Target table name')
@click.option('--chunksize', default=100000, type=int, help='Chunk size for reading CSV')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, year, month, target_table, chunksize):
    """Ingest NYC taxi data into PostgreSQL database."""
    prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
    url = f'{prefix}/yellow_tripdata_{year}-{month:02d}.csv.gz'

    engine = create_engine(f'postgresql+psycopg://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

    df_iter = pd.read_csv(
        url,
        dtype=dtype,
        parse_dates=parse_dates,
        iterator=True,
        chunksize=chunksize,
    )

    first = True

    for df_chunk in tqdm(df_iter):
        if first:
            df_chunk.head(0).to_sql(
                name=target_table,
                con=engine,
                if_exists='replace'
            )
            first = False

        df_chunk.to_sql(
            name=target_table,
            con=engine,
            if_exists='append'
        )

if __name__ == '__main__':
    run()
```

[pyproject.toml]
- Dependencies list: click, pandas, psycopg2-binary, pyarrow, sqlalchemy, tqdm.
- Dev Dependencies: jupyter, pgcli.
```toml
[project]
name = "pipeline"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.13"
dependencies = [
    "click>=8.3.1",
    "pandas>=2.3.3",
    "psycopg2-binary>=2.9.11",
    "pyarrow>=22.0.0",
    "sqlalchemy>=2.0.44",
    "tqdm>=4.67.1",
]

[dependency-groups]
dev = [
    "jupyter>=1.1.1",
    "pgcli>=4.3.0",
]
```

[docker-pgadmin.sh / docker-postgres.sh]
- Làm gì: Khởi chạy container pgAdmin/Postgres thủ công bằng lệnh bash `docker run`.
- Arguments: hardcode env vars, chỉ định network `pg-network`, map volumes về thư mục local lân cận (`../`).
- Cấu hình: (Copy nguyên văn bên dưới)
```bash
#!/usr/bin/env bash

## bash script to start pgadmin
echo "Starting pgAdmin container..."
mkdir -p ../pgadmin_data

docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v ../pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```
```bash
#!/usr/bin/env bash

## bash script to start the Postgres container
mkdir -p ../ny_taxi_postgres_data

echo "Starting PostgreSQL container..."

docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ../ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18

# to use the pgcli
# pgcli -h localhost -p 5432 -u root -d ny_taxi
```

[terraform_basic/main.tf]
```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
# Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
#  credentials = 
  project = "<Your Project ID>"
  region  = "us-central1"
}



resource "google_storage_bucket" "data-lake-bucket" {
  name          = "<Your Unique Bucket Name>"
  location      = "US"

  # Optional, but recommended settings:
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}


resource "google_bigquery_dataset" "dataset" {
  dataset_id = "<The Dataset Name You Want to Use>"
  project    = "<Your Project ID>"
  location   = "US"
}
```

[terraform_with_variables/main.tf + variables.tf]
- Resources được tạo: `google_storage_bucket`, `google_bigquery_dataset`.
- Variables: 
  - `credentials`: string (default: `<Path to your Service Account json file>`)
  - `project`: string (default: `<Your Project ID>`)
  - `region`: string (default: `us-central1`)
  - `location`: string (default: `US`)
  - `bq_dataset_name`: string (default: `demo_dataset`)
  - `gcs_bucket_name`: string (default: `terraform-demo-terra-bucket`)
  - `gcs_storage_class`: string (default: `STANDARD`)
```terraform
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}


resource "google_storage_bucket" "demo-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true


  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}



resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}
```
```terraform
variable "credentials" {
  description = "My Credentials"
  default     = "<Path to your Service Account json file>"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}


variable "project" {
  description = "Project"
  default     = "<Your Project ID>"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default     = "us-central1"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "terraform-demo-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}
```

[terraform_with_variable_AWS/main.tf + variables.tf + terraform.tfvars]
```terraform
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

#S3 Bucket to store data equivalent to GCS Bucket in GCP
resource "aws_s3_bucket" "data_lake_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

#Bucket verisioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_lake_bucket.id # Reference the S3 bucket created above

  versioning_configuration {
    status = "Enabled" # Enable versioning
  }
}

# "Uniform bucket level access" ~ control prin policy/ACL; recomandat: block public access
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.data_lake_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle: delete objects older than 30 days (echivalent lifecycle_rule age=30)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rules" {
  bucket = aws_s3_bucket.data_lake_bucket.id

  rule {
    id     = "Delete_old_older_than_30_days"
    status = "Enabled"

    expiration {
      days = 30
    }
    filter {
      prefix = "" # Apply to all objects in the bucket
    }
  }
}

resource "aws_glue_catalog_database" "dataset" {
  name = var.dataset_name
}
```
```terraform
# Specifies the geographic location for AWS resource deployment.
# Defaulting to Stockholm (eu-north-1) to keep latency low for European users.
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type = string
  default = "eu-north-1"

}

# The unique identifier for the S3 bucket where raw data will be stored.
# S3 bucket names must be globally unique across all AWS accounts.
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "data-engineering-zoomcamp-1568692036"
}

# Defines the logical grouping for metadata in the AWS Glue Catalog.
# This allows tools like Athena to query the S3 data using SQL.
variable "dataset_name" {
  description = "Glue Catalog database name (logical dataset for Athena/Glue)"
  type        = string
  default = "ny_taxi_database"
}
```
```terraform
bucket_name  = "my-unique-data-lake-bucket-12345"
dataset_name = "ny_taxi_dataset"
```

═══════════════════════════════
4. DATA FLOW THỰC TẾ
═══════════════════════════════
- Flow đầy đủ: Github Releases (File `.csv.gz`) → Python Ingestion Script (`ingest_data.py`) đọc theo dạng chunk qua Pandas → SQLAlchemy Engine → PostgreSQL Database.
- File nào trigger file nào: 
  - `docker-compose.yaml` (chạy ngầm) trigger `postgres` và `pgadmin` containers.
  - User trigger bash lệnh `docker run ... taxi_ingest:v001` (hoặc thông qua `docker-ingest.sh`). Lệnh này gọi `ENTRYPOINT ["python", "ingest_data.py"]` định nghĩa trong `Dockerfile`.
- Thứ tự chạy đúng:
  1. `docker-compose up -d` (Lên database và pgadmin trước).
  2. Truy cập web browser để login pgAdmin, kết nối tới Server.
  3. Xây dựng image ingest bằng lệnh `docker build -t taxi_ingest:v001 .`
  4. Chạy container ingest kết nối với network của Postgres.
- Dependency giữa các services: `taxi_ingest` phụ thuộc vào `pgdatabase` đã chạy sẵn và chung mạng (Network), `pgadmin` phụ thuộc vào network để nhìn thấy `pgdatabase`.

═══════════════════════════════
5. ĐIỂM YẾU & THIẾU SÓT
═══════════════════════════════
- Security issues: Thông tin nhạy cảm (User, Password) đều đang bị hardcode cứng vào file bash, file python default values, và file `docker-compose.yaml` (ví dụ `root`:`root`). Không hề dùng `.env` hay Secret Manager.
- Idempotency issues: `ingest_data.py` lặp qua chunk dùng `if_exists='append'`. Không lưu lại trạng thái chunk (watermark/checkpoint). Nếu mạng đứt, quá trình chạy lại sẽ bị trùng dữ liệu.
- Production readiness gaps: Xử lý file từ URL là một block duy nhất, nếu rớt kết nối mạng sẽ báo lỗi OOM hoặc văng exception, không có block `try-catch`, retry mechanism hay log formatting. Tên file được gen từ arguments year, month -> chưa linh hoạt bằng cơ chế list directory/API trên GCS/S3.
- Monitoring gaps: Thiếu vắng hoàn toàn các công cụ ghi log có cấu trúc hay metric monitoring. Chỉ có thanh progress bar của `tqdm`.
- Những gì repo dạy nhưng không đủ: Terraform state đang lưu local `.tfstate`, ở môi trường production phải dùng remote state backend (GCS, S3, Terraform Cloud) và state locking (DynamoDB).

═══════════════════════════════
6. KIẾN THỨC NGOÀI REPO (Dành cho Senior DE)
═══════════════════════════════
Dựa trên kiến thức cơ bản repo đang cover, Senior DE phải biết thêm:
- Docker: 
  - Tối ưu kích thước Image (Distroless, Alpine, Multi-stage build gắt gao hơn).
  - Quản lý Docker Secrets.
  - Sử dụng Healthchecks cho `depends_on` (Đảm bảo Postgres "ready to accept connections" trước khi chạy Ingest).
  - Phân quyền user (Non-root users) thay vì chạy với root theo mặc định.
- Terraform:
  - Remote State Backend (lưu `.tfstate` trên Bucket Cloud) + State Locking.
  - Sử dụng Terraform Modules để tái sử dụng code.
  - CI/CD Pipelines (Github Actions / Gitlab CI) để tự động hóa `terraform plan` & `apply`.
  - Quản lý Workspace cho nhiều môi trường (dev, stg, prod).
- Pipeline/Ingestion:
  - Idempotent Data Load: Upsert logic (MERGE statement) thay vì `append`, hoặc xử lý dữ liệu qua logic Partitioning (Xóa partition bị lỗi trước khi nạp lại).
  - Error Handling & Retry Policies (Dùng kịch bản backoff/Tenacity).
  - Sử dụng Orchestrators xịn sò (Airflow, Dagster, Prefect) thay vì bash scripts tay.
- GCP/AWS:
  - Service Account Least Privilege (cấp quyền vừa đủ cho service account thay vì cấp Storage Admin toàn quyền).
  - Tự động hóa kết nối an toàn (IAM Auth / Workload Identity) thay vì ném JSON Keys lên máy tính cá nhân/container.
```
