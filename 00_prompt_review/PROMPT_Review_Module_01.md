# PROMPT_Review_Module_01.md
# Checklist kiến thức cụ thể — Module 01: Docker + Terraform
# Dùng KẾT HỢP với PROMPT_Review_Generic.md

```
Đây là checklist kiến thức bắt buộc cho Module 01 — Docker + Terraform.
Dùng để đối chiếu với file Module01_Docker_Terraform.html đang review.
Repo cần đọc: data-engineering-zoomcamp/01-docker-terraform/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN A — KIỂM TRA BÁM SÁT REPO THỰC TẾ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Thông tin CHÍNH XÁC từ repo — kiểm tra file HTML có khớp không:

── docker-compose.yaml ──
- [ ] Service 1 tên đúng: "pgdatabase" (không phải "postgres")
- [ ] Service 2 tên đúng: "pgadmin"
- [ ] pgdatabase image đúng: postgres:18 (không phải latest hay 13)
- [ ] pgadmin image đúng: dpage/pgadmin4
- [ ] Port pgdatabase: "5432:5432"
- [ ] Port pgadmin: "8085:80" (không phải 8080:8080)
- [ ] pgdatabase env vars: POSTGRES_USER="root", POSTGRES_PASSWORD="root", POSTGRES_DB="ny_taxi"
- [ ] pgadmin env vars: PGADMIN_DEFAULT_EMAIL="admin@admin.com", PGADMIN_DEFAULT_PASSWORD="root"
- [ ] Volume pgdatabase: ny_taxi_postgres_data:/var/lib/postgresql
- [ ] Volume pgadmin: pgadmin_data:/var/lib/pgadmin
- [ ] Named volumes cuối file: ny_taxi_postgres_data, pgadmin_data
- [ ] KHÔNG có depends_on → đây là điểm yếu cần chỉ ra (race condition)
- [ ] KHÔNG có network khai báo riêng → dùng default network của compose

── Dockerfile ──
- [ ] Base image: python:3.13.11-slim
- [ ] Dùng uv (không phải pip): COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/
- [ ] WORKDIR: /code
- [ ] ENV PATH: "/code/.venv/bin:$PATH"
- [ ] Thứ tự COPY đúng: pyproject.toml + .python-version + uv.lock → RUN uv sync --locked → COPY ingest_data.py
- [ ] ENTRYPOINT: ["python", "ingest_data.py"]
- [ ] Điểm yếu: không multi-stage build, chạy root user

── ingest_data.py ──
Arguments thực tế (dùng click, không phải argparse):
- [ ] --pg-user, --pg-pass, --pg-host, --pg-port, --pg-db
- [ ] --year (default: 2021), --month (default: 1)
- [ ] --target-table (default: yellow_taxi_data)
- [ ] --chunksize (default: 100000)
- [ ] URL tạo từ year/month:
      prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
      url = f'{prefix}/yellow_tripdata_{year}-{month:02d}.csv.gz'
- [ ] Connection string đúng: postgresql+psycopg://{user}:{pass}@{host}:{port}/{db}
- [ ] Logic chunk: chunk đầu if_exists='replace', chunk sau if_exists='append'
- [ ] Dùng tqdm progress bar
- [ ] Điểm yếu phải chỉ ra:
      * KHÔNG idempotent: chạy lại 2 lần = duplicate data
      * KHÔNG có try-catch, retry
      * KHÔNG có structured logging
      * KHÔNG có checkpoint khi fail giữa chừng
      * Credentials hardcode trong default values

── Shell Scripts ──
- [ ] docker-postgres.sh: chạy postgres với --network=pg-network --name pgdatabase
- [ ] docker-pgadmin.sh: chạy pgadmin với --network=pg-network --name pgadmin
- [ ] Dùng manual network (pg-network) thay vì docker-compose network
- [ ] Hardcode credentials trong scripts (điểm yếu)

── pyproject.toml ──
Dependencies thực tế:
- [ ] click>=8.3.1, pandas>=2.3.3, psycopg2-binary>=2.9.11
- [ ] pyarrow>=22.0.0, sqlalchemy>=2.0.44, tqdm>=4.67.1
- [ ] Dev: jupyter, pgcli

── Terraform (terraform_with_variables) ──
- [ ] Provider version: google "5.6.0"
- [ ] Resource 1: google_storage_bucket "demo-bucket"
      * gcs_bucket_name (default: "terraform-demo-terra-bucket")
      * force_destroy = true
      * lifecycle_rule: AbortIncompleteMultipartUpload sau 1 ngày
- [ ] Resource 2: google_bigquery_dataset "demo_dataset"
      * bq_dataset_name (default: "demo_dataset")
- [ ] Credentials: file(var.credentials)
- [ ] Variables: credentials, project, region, location, bq_dataset_name,
      gcs_bucket_name, gcs_storage_class
- [ ] Điểm yếu: gcs_storage_class khai báo nhưng KHÔNG dùng (dead variable)
- [ ] Điểm yếu: không có backend block → state lưu local
- [ ] Điểm yếu: credentials path hardcode trong default value

── AWS variant ──
- [ ] Repo có terraform_with_variable_AWS cho learner không dùng GCP
- [ ] GCS → S3 Bucket, BigQuery → AWS Glue Catalog
- [ ] terraform.tfvars gán giá trị cụ thể (GCP version không có file này)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN B — CHECKLIST KIẾN THỨC DOCKER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGINNER (phải có đủ):
- [ ] Container vs VM: kernel sharing, overhead, startup time
- [ ] Image vs Container: image = blueprint, container = running instance
- [ ] Dockerfile instructions: FROM, RUN, COPY, CMD, ENTRYPOINT
- [ ] Layer caching: thứ tự COPY quan trọng
      (pyproject.toml TRƯỚC ingest_data.py để cache deps layer)
- [ ] docker-compose: tại sao cần, orchestrate multi-container
- [ ] Lệnh cơ bản: run, ps, logs, exec, stop, rm, build
- [ ] Port mapping: HOST:CONTAINER (8085:80 → port 8085 host map vào 80 container)
- [ ] Volume: named vs bind mount (repo dùng cả 2)
- [ ] uv: tại sao repo dùng uv thay pip, lợi ích gì

INTERMEDIATE (phải có đủ):
- [ ] depends_on vs healthcheck: repo KHÔNG có depends_on → race condition thực tế
- [ ] Network: hostname = container name (pgdatabase thay vì localhost)
- [ ] Environment variables: compose vs .env file (repo hardcode → điểm yếu)
- [ ] .dockerignore: build context, tại sao quan trọng
- [ ] Image tagging: v001 tốt hơn latest (repo đã làm đúng)
- [ ] Restart policies: repo không set → điểm yếu
- [ ] docker-compose down vs down -v: khác nhau thế nào

SENIOR (phải có ít nhất 4/7):
- [ ] Multi-stage builds: Dockerfile hiện tại không dùng → image size lớn hơn cần thiết
- [ ] Resource limits: không có trong compose → production cần --memory, --cpus
- [ ] Docker security: root user trong container → security risk
- [ ] Health check production: pg_isready thay vì chỉ depends_on
- [ ] Registry: push lên GCR thay vì chỉ build local
- [ ] Khi nào Compose không đủ → Kubernetes/Cloud Run
- [ ] Docker secrets thay thế env vars cho sensitive data

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN C — CHECKLIST KIẾN THỨC TERRAFORM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGINNER (phải có đủ):
- [ ] IaC vs ClickOps: tại sao IaC tốt hơn
- [ ] Workflow: init → plan → apply → destroy
- [ ] Provider: google version "5.6.0", tại sao pin version
- [ ] Resource: google_storage_bucket, google_bigquery_dataset
- [ ] Variable: khai báo, default, cách truyền giá trị
- [ ] State file: terraform.tfstate, lưu local mặc định
- [ ] ADC: gcloud auth application-default login

INTERMEDIATE (phải có đủ):
- [ ] State file rủi ro: sensitive data, mất state → mất track hạ tầng
- [ ] Remote state: GCS backend, tại sao cần
- [ ] State locking: tránh concurrent apply
- [ ] terraform.tfvars: gán giá trị, không commit git (repo có cho AWS variant)
- [ ] force_destroy: nguy hiểm trong production
- [ ] lifecycle_rule: AbortIncompleteMultipartUpload → tiết kiệm cost
- [ ] Dead variable: gcs_storage_class khai báo nhưng không dùng → code smell

SENIOR (phải có ít nhất 4/7):
- [ ] Workspace: dev/staging/prod environments
- [ ] Module: tái sử dụng, public registry
- [ ] CI/CD: GitHub Actions plan on PR, apply on merge
- [ ] Drift detection: ai sửa tay trên console → plan phát hiện
- [ ] Least privilege IAM: Storage Admin quá rộng → custom role
- [ ] Workload Identity thay JSON key file
- [ ] Secret management: credentials không nên trong variables.tf default

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN D — PRODUCTION THINKING CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FAILURE (S4.1):
- [ ] Đúng lệnh: docker logs pgdatabase, docker-compose logs -f
- [ ] Partial insert problem: fail ở chunk 5/10 → 500k rows trong DB
      chạy lại → if_exists='replace' xóa hết rồi append lại → risk mất data
- [ ] Code fix: try-catch + checkpoint lưu chunk index đã xử lý

SCALE (S4.2):
- [ ] Bottleneck đúng: single Python process, single DB connection
- [ ] Đề xuất: connection pooling, parallel ingestion theo partition year/month
- [ ] Khi nào rời Compose: cần horizontal scale → K8s/Cloud Run

IDEMPOTENCY (S4.3):
- [ ] if_exists='append' không idempotent
- [ ] Code example fix:
      Option 1: TRUNCATE table trước khi ingest
      Option 2: staging table → MERGE/UPSERT vào target
- [ ] Trade-off giữa 2 options

MONITORING (S4.4):
- [ ] Health check thực tế cho postgres:
      test: ["CMD-SHELL", "pg_isready -U root -d ny_taxi"]
- [ ] SQL verify: SELECT COUNT(*), MAX(tpep_pickup_datetime) FROM yellow_taxi_data
- [ ] Alert: script check row count sau ingest, curl webhook Slack

COST (S4.5):
- [ ] GCS: ~$0.02/GB/tháng
- [ ] BigQuery: $5/TB query on-demand
- [ ] lifecycle_rule trong repo → giải thích tiết kiệm cost
- [ ] Đề xuất thêm lifecycle rule xóa raw files sau N ngày

SECURITY (S4.6):
- [ ] Credentials hardcode: root:root trong compose, shell scripts → .env + .gitignore
- [ ] Terraform state → remote state với encryption
- [ ] Service account JSON → Workload Identity
- [ ] IAM least privilege: Storage Admin → custom role

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN E — INTERVIEW QUESTIONS CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

JUNIOR (4 câu):
- [ ] Container vs VM: kernel sharing, startup time, overhead
- [ ] docker-compose up -d vs docker run: orchestration, networking tự động
- [ ] State file: không chỉ "lưu trạng thái" — sensitive data, mất state risk
- [ ] Plan trước Apply: preview changes, tránh surprise, production safety

MID (4 câu):
- [ ] Volume: named volume vs bind mount, docker-compose down -v mất data
- [ ] Concurrent apply: state locking cụ thể
- [ ] variables.tf vs hardcode: security + reusability
- [ ] Layer cache: thứ tự COPY trong Dockerfile (pyproject.toml trước script)

SENIOR (4 câu):
- [ ] Production setup: health checks + depends_on condition, restart policies,
      resource limits, non-root user, .env
- [ ] Mất state: terraform state list → terraform import từng resource
- [ ] Partial ingest: staging table + MERGE, hoặc checkpoint file, code example
- [ ] 5 DE team: remote state + locking, branch strategy, workspace, review trước apply

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN F — RED FLAGS CẦN PHÁT HIỆN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Báo lỗi ngay nếu file HTML có:

- [ ] pgadmin port là 8080 thay vì 8085 (sai repo)
- [ ] Service tên "postgres" thay vì "pgdatabase" (sai repo)
- [ ] postgres image là latest hay 13 thay vì postgres:18 (sai repo)
- [ ] Không đề cập uv (bỏ qua điểm quan trọng của repo)
- [ ] Dùng "latest" tag trong production example không cảnh báo
- [ ] Không đề cập .gitignore cho .env và terraform.tfstate
- [ ] Giải thích depends_on không nói không đảm bảo service ready
      (repo KHÔNG có depends_on → race condition thực tế)
- [ ] Không đề cập idempotency issue của if_exists='append'
- [ ] terraform destroy không cảnh báo force_destroy=true nguy hiểm
- [ ] Bài tập dùng --url argument (không có trong repo, repo dùng --year/--month)
- [ ] Không đề cập AWS variant trong repo
- [ ] Connection string sai: postgresql:// thay vì postgresql+psycopg://
- [ ] Không đề cập dead variable gcs_storage_class
- [ ] Interview Senior mà thực ra chỉ ở Junior level
```
