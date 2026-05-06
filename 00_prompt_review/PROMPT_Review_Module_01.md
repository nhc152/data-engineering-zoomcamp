# PROMPT_Review_Module_01.md
# Checklist kiến thức cụ thể — Module 01: Docker + Terraform
# Dùng KẾT HỢP với PROMPT_Review_Generic.md

```
Đây là checklist kiến thức bắt buộc cho Module 01 — Docker + Terraform.
Dùng để đối chiếu với file Module01_Docker_Terraform.html đang review.
Repo cần đọc: data-engineering-zoomcamp/01-docker-terraform/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN A — KIỂM TRA BÁM SÁT REPO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Đọc repo rồi kiểm tra file HTML có cover đúng không:

docker-compose.yaml:
- [ ] Giải thích đúng tên services (postgres, pgadmin)
- [ ] Port mapping đúng (5432:5432, 8080:8080) và giải thích tại sao
- [ ] Environment variables đúng (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB)
- [ ] Volume mount path đúng với repo
- [ ] Network config nếu có trong repo

ingest_data.py:
- [ ] Giải thích đúng arguments (user, password, host, port, db, table, url)
- [ ] Chunk reading logic (pd.read_csv với iterator + chunksize)
- [ ] SQLAlchemy connection string đúng format
- [ ] Chỉ ra được điểm yếu: không idempotent, không retry, không validation

main.tf (Terraform):
- [ ] Provider block đúng (google provider, project, region, credentials)
- [ ] Resource types đúng với repo (google_storage_bucket, google_bigquery_dataset)
- [ ] Variable references đúng (var.project, var.region, var.bq_dataset...)
- [ ] Lifecycle/force_destroy nếu có trong repo

variables.tf:
- [ ] Các variables đúng với repo (project, region, location, bq_dataset, gcs_bucket...)
- [ ] Default values đúng
- [ ] Giải thích tại sao tách variables.tf riêng

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN B — CHECKLIST KIẾN THỨC DOCKER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGINNER (phải có đủ):
- [ ] Container vs VM: sự khác biệt core (kernel sharing, overhead, startup time)
- [ ] Image vs Container: image = blueprint, container = running instance
- [ ] Dockerfile: FROM, RUN, COPY, CMD, ENTRYPOINT — mỗi instruction làm gì
- [ ] Layer caching: tại sao thứ tự instruction trong Dockerfile quan trọng
- [ ] docker-compose: tại sao cần, orchestrate multi-container
- [ ] Các lệnh cơ bản: run, ps, logs, exec, stop, rm, build, pull, push
- [ ] Port mapping: HOST:CONTAINER nghĩa là gì
- [ ] Volume: tại sao cần, named vs anonymous vs bind mount

INTERMEDIATE (phải có đủ):
- [ ] docker-compose depends_on vs healthcheck: khác nhau thế nào, cái nào reliable hơn
- [ ] Network modes: bridge (default), host, none — khi nào dùng cái nào
- [ ] Environment variables: trong Dockerfile vs docker-compose vs .env file
- [ ] Docker build context: tại sao .dockerignore quan trọng
- [ ] Image tagging strategy: latest vs semantic versioning
- [ ] docker-compose override files: dev vs production config
- [ ] Container restart policies: no, always, unless-stopped, on-failure

SENIOR (phải có ít nhất 4/7):
- [ ] Multi-stage builds: giảm image size, tách build env vs runtime env
- [ ] Resource limits: --memory, --cpus trong compose — tại sao cần trong production
- [ ] Docker security: non-root user, read-only filesystem, capability dropping
- [ ] Health check production-grade: HTTP endpoint check vs process check
- [ ] Registry management: Docker Hub vs GCR vs ECR, image scanning
- [ ] Container orchestration: khi nào Docker Compose không đủ → Kubernetes
- [ ] Docker networking deep dive: DNS resolution giữa containers, overlay network

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN C — CHECKLIST KIẾN THỨC TERRAFORM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGINNER (phải có đủ):
- [ ] IaC là gì: Infrastructure as Code vs ClickOps — tại sao IaC tốt hơn
- [ ] Terraform workflow: init → plan → apply → destroy
- [ ] Provider: là gì, cách khai báo, version pinning
- [ ] Resource: là gì, syntax cơ bản, resource types phổ biến (GCS, BQ)
- [ ] Variable: input variable, cách khai báo, cách truyền giá trị
- [ ] Output: là gì, dùng để làm gì
- [ ] State file: terraform.tfstate là gì, lưu ở đâu, chứa gì

INTERMEDIATE (phải có đủ):
- [ ] State file rủi ro: mất state → mất track hạ tầng, sensitive data trong state
- [ ] Remote state: tại sao cần, cách config GCS backend
- [ ] State locking: tránh concurrent apply, cơ chế lock
- [ ] Data sources: khác resource ở chỗ nào, khi nào dùng
- [ ] terraform.tfvars: cách dùng, không commit lên git
- [ ] Depends_on implicit vs explicit: Terraform tự detect dependency thế nào
- [ ] terraform import: khi nào cần, cách dùng

SENIOR (phải có ít nhất 4/7):
- [ ] Workspace: dev/staging/prod separation, khi nào dùng workspace vs separate state
- [ ] Module: tái sử dụng config, cách tạo module, registry
- [ ] CI/CD cho Terraform: plan on PR, apply on merge, atlantis/terraform cloud
- [ ] Drift detection: hạ tầng bị ai đó sửa tay → terraform plan phát hiện thế nào
- [ ] Terragrunt: tại sao cần, DRY principle cho Terraform
- [ ] Provider version constraints: ~>, >=, = — semantic versioning
- [ ] Secret management: không lưu secret trong .tf, dùng Secret Manager/Vault

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN D — PRODUCTION THINKING CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

6 câu S4 phải trả lời được ở mức này:

FAILURE (S4.1):
- [ ] Chỉ đúng nơi check log: docker logs <container>, docker-compose logs -f
- [ ] Giải thích partial insert problem khi ingest fail giữa chừng
- [ ] Có code example fix idempotency trong ingest_data.py

SCALE (S4.2):
- [ ] Chỉ ra đúng bottleneck: single Python process, single DB connection
- [ ] Đề xuất cụ thể: chunking, parallel ingestion, connection pooling
- [ ] Đề cập khi nào cần rời khỏi Docker Compose

IDEMPOTENCY (S4.3):
- [ ] Giải thích tại sao script hiện tại KHÔNG idempotent
- [ ] Có code example: TRUNCATE + INSERT hoặc ON CONFLICT DO UPDATE
- [ ] Phân biệt được 2 approach và khi nào dùng cái nào

MONITORING (S4.4):
- [ ] Health check config trong docker-compose (không chỉ depends_on)
- [ ] Có query SQL kiểm tra row count, max ingested timestamp
- [ ] Đề cập ít nhất 1 cách alert thực tế (webhook, email script)

COST (S4.5):
- [ ] Có con số ước tính GCS: ~$0.02/GB/tháng
- [ ] Có con số ước tính BigQuery: $5/TB query
- [ ] Đề cập lifecycle policy cho GCS (tự xóa file cũ)

SECURITY (S4.6):
- [ ] Chỉ ra rõ: .env file không được commit lên git
- [ ] Giải thích terraform state chứa sensitive data → cần encrypt remote state
- [ ] Đề xuất Secret Manager thay vì biến môi trường cho production

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN E — INTERVIEW QUESTIONS CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

12 câu S7 phải đạt level này:

JUNIOR (4 câu) — kiểm tra xem có thực sự Junior level không:
- [ ] Câu 1 phân biệt Container vs VM không chỉ bằng định nghĩa mà bằng use case
- [ ] Câu 2 giải thích được docker-compose up -d vs docker run
- [ ] Câu 3 giải thích state file không chỉ là "lưu trạng thái" mà giải thích được rủi ro
- [ ] Câu 4 giải thích được plan trước apply — tại sao critical trong production

MID (4 câu) — kiểm tra trade-off thinking:
- [ ] Câu 5 về volume persistence phải đề cập named volume vs bind mount
- [ ] Câu 6 về concurrent terraform apply phải đề cập state locking cụ thể
- [ ] Câu 7 về variables.tf phải đề cập security (không hardcode sensitive values)
- [ ] Câu 8 về image rebuild phải đề cập layer cache và build time optimization

SENIOR (4 câu) — kiểm tra system design thinking:
- [ ] Câu 9 (10 services) phải đề cập health checks, restart policies, resource limits
- [ ] Câu 10 (mất state) phải có recovery procedure cụ thể từng bước
- [ ] Câu 11 (partial ingest) phải có idempotent solution với code
- [ ] Câu 12 (5 DE team) phải đề cập remote state + locking + branch strategy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PHẦN F — RED FLAGS CẦN PHÁT HIỆN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Báo lỗi ngay nếu file HTML có những điều này:

- [ ] Dùng "latest" tag cho Docker image trong production example mà không cảnh báo
- [ ] Không đề cập .gitignore cho .env và terraform.tfstate
- [ ] Giải thích depends_on mà không nói nó không đảm bảo service ready
- [ ] Không đề cập idempotency của ingest_data.py
- [ ] terraform destroy không có cảnh báo về production risk
- [ ] Bài tập thực hành dùng command không tồn tại hoặc sai syntax
- [ ] Interview câu Senior mà thực ra chỉ ở Junior level
- [ ] Code example không chạy được (sai indent Python, sai YAML format)
- [ ] Không đề cập version pinning cho Terraform provider
```
