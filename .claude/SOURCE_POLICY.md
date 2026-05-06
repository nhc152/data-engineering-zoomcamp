# Source Policy

## Thứ tự đọc source (bắt buộc theo thứ tự này)

1. `master_de_roadmap.md` — đọc section tương ứng với module đang build
2. `data-engineering-zoomcamp/[module]/` — đọc TOÀN BỘ code thực tế
3. `file_mau_tham_khao_can_nang_cap.html` — lấy CSS variables, JS patterns, component structure
4. File output đang build — giữ consistency nếu đang update file đã có

---

## Quy trình đọc repo (bắt buộc trước khi viết)

**Bước 1 — Đọc tổng quan**
- README.md của module
- Cấu trúc thư mục (tên folder, tên file nói lên gì?)

**Bước 2 — Đọc config files trước**
- `docker-compose.yaml` / `.yml`
- `*.tf` (Terraform)
- `*.yaml` (Kestra/Airflow DAGs)
- `.env.example`

**Bước 3 — Đọc code chính**
- Python scripts (ingest, transform, pipeline)
- SQL files nếu có
- Tìm entry point: file nào chạy đầu tiên?

**Bước 4 — Map data flow**
- Vẽ mentally: data đi từ đâu → qua đâu → đến đâu
- Ai gọi ai? File nào phụ thuộc file nào?

**Sau đó mới bắt đầu viết content.**

---

## File mapping theo module

| Module | Folder cần đọc | Files quan trọng nhất |
|---|---|---|
| 01 | `01-docker-terraform/` | `docker-compose.yaml`, `ingest_data.py`, `main.tf` |
| 02 | `02-workflow-orchestration/` | DAG files `.yaml`/`.py`, pipeline scripts |
| 03 | `03-data-warehouse/` | SQL scripts, BQ configs, GCS setup |
| 04 | `04-analytics-engineering/` | `models/`, `dbt_project.yml`, `schema.yml` |
| 05 | `05-data-platforms/` | Pipeline config, asset definitions |
| 06 | `06-batch/` | PySpark scripts, Spark configs |
| 07 | `07-streaming/` | Kafka configs, Flink jobs, producer/consumer scripts |

---

## Reference từ master_de_roadmap.md

Mỗi module trong roadmap có sẵn:
- **Beginner / Intermediate / Senior** breakdown
- **Senior Questions** (fail, scale, cost) — phải cover trong M4
- **Pro-tier patterns** — phải cover trong M5
- **7-ngày execution plan** — dùng làm gợi ý cho phần thực hành M3
- **Incident Simulation** — dùng cho M6 lỗi thường gặp
- **Interview Mapping (STAR)** — dùng cho M7

---

## External Knowledge Policy

Được phép dùng kiến thức ngoài repo khi:
- Repo chỉ dạy đến Intermediate, cần nâng lên Senior depth
- Cần so sánh với alternatives (Airflow vs Kestra, Spark vs Flink, BQ vs Snowflake...)
- Cần production best practices (monitoring, cost optimization, security)
- Cần giải thích internals (tại sao Kafka dùng append-only log, tại sao Spark lazy evaluation)

Khi dùng external knowledge:
- Luôn kết nối về use case trong repo đang học
- Focus vào Data Engineering production context
- Không lan sang topic không liên quan module

---

## Safety Rules

- KHÔNG modify bất kỳ file nào trong `data-engineering-zoomcamp/` — read-only
- KHÔNG modify `master_de_roadmap.md` trừ khi được yêu cầu rõ
- KHÔNG modify `file_mau_tham_khao_can_nang_cap.html` — chỉ đọc để lấy patterns
- Output HTML luôn là file mới, tên theo convention `ModuleXX_TopicName.html`
