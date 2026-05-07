# PROMPT_Review_Module_02.md
# Review chuyên sâu: Module 02 — Workflow Orchestration (Kestra)

> Dùng sau khi đã build xong theo PROMPT_Build_Module_02.
> Dùng kết hợp với PROMPT_Review_Generic.md (review chung).
> Output của prompt này là input cho PROMPT_Patch_After_Review.md.

---

## CONTEXT CHO REVIEWER

Bạn là **Senior Data Engineer** đang review toàn bộ implementation của Module 02 —
Workflow Orchestration dùng **Kestra v1.1**.

Stack:
- Kestra v1.1 (standalone server, port 8080/8081)
- Postgres 18 × 2: `pgdatabase` (ny_taxi, port 5432) + `kestra_postgres` (metadata)
- pgAdmin (port 8085)
- GCP: GCS bucket + BigQuery dataset `zoomcamp`
- Flows: `01_hello_world` → `09_gcp_taxi_scheduled` (flows 10/11 AI/RAG optional)

Namespace Kestra: `zoomcamp`

---

## CHECKLIST REVIEW — ĐỌC TỪNG MỤC, TRẢ LỜI CỤ THỂ

### ════════════════════════════════
### BLOCK A — INFRASTRUCTURE (docker-compose.yml)
### ════════════════════════════════

**A1. Service dependency order**
- `pgdatabase` depends_on `kestra` (condition: service_started) — đây là VÒNG LẶP dependency.
  Kestra lại depends_on `kestra_postgres`. Thứ tự startup thực tế có bị deadlock không?
- Xác nhận: tất cả 4 services (kestra_postgres, kestra, pgdatabase, pgadmin) đều UP sau `docker compose up -d`.

**A2. Volume mounting**
- Kestra mount `/var/run/docker.sock` — confirm Docker-in-Docker hoạt động cho Python task runner.
- Volume `kestra_tmp` mount vào `/tmp/kestra-wd` — confirm tasks có thể write temp files.

**A3. Credentials exposure**
- Liệt kê tất cả credentials hardcode trong docker-compose.yml:
  - Postgres ny_taxi: `root/root`
  - Kestra basic auth: `admin@kestra.io / Admin1234!`
  - Kestra metadata DB: `kestra/k3str4`
- Đây có phải vấn đề không? Mức độ rủi ro trong context học tập vs production?

**A4. Port conflicts**
- Ports đang expose: 5432, 8080, 8081, 8085
- Có port nào thường bị conflict trên máy developer không? Cách kiểm tra trước khi up?

---

### ════════════════════════════════
### BLOCK B — KESTRA CONCEPTS (flows 01–03)
### ════════════════════════════════

**B1. Flow 01 — Hello World**
- `pluginDefaults` set `level: ERROR` cho Log tasks → log message sẽ chỉ hiện nếu level ERROR.
  Nhưng task dùng `io.kestra.plugin.core.log.Log` với message bình thường.
  Behavior thực tế: message có hiện trong UI không? Level có bị override không?
- `concurrency: behavior: FAIL, limit: 2` — trigger cùng lúc 3 execution → execution thứ 3 FAIL ngay hay queue?
- Schedule trigger đang `disabled: true` — confirm disabled trigger không tự chạy.

**B2. Flow 02 — Python Docker runner**
- `taskRunner: type: io.kestra.plugin.scripts.runner.docker.Docker` — Kestra có pull image `python:slim` từ DockerHub hay dùng local cache?
- `dependencies: [requests, kestra]` được install lúc nào — mỗi lần execute hay được cache?
- `Kestra.outputs(outputs)` — output `downloads` có accessible từ `outputs.collect_stats.vars.downloads` không? Verify expression đúng.
- Network: container Python task có access ra internet (DockerHub API) không? Nếu không có internet thì flow fail ở bước nào?

**B3. Flow 03 — Mini ETL Pipeline**
- `inputFiles: data.json: "{{outputs.extract.uri}}"` — URI này là Kestra internal storage URI hay local path? Task Python có đọc được không?
- `outputFiles: ["*.json"]` — glob pattern capture đúng `products.json` không?
- `env: COLUMNS_TO_KEEP: "{{inputs.columns_to_keep}}"` — ARRAY input serialize thành string gì? `json.loads()` có parse được không?
- DuckDB task: `{{workingDir}}` — path này trỏ đến đâu trong container DuckDB? File `products.json` có được copy vào đó không?
- `fetchType: STORE` — result lưu ở đâu? Xem được trong Kestra UI không?

---

### ════════════════════════════════
### BLOCK C — POSTGRES ETL (flows 04–05)
### ════════════════════════════════

**C1. Flow 04 — Idempotency check (QUAN TRỌNG)**
- Chạy flow 04 với `yellow/2019/01` → ghi lại row count sau lần 1.
- Chạy lại y hệt → row count có thay đổi không?
- Expected: KHÔNG thay đổi (MERGE WHEN NOT MATCHED).
- Nếu row count tăng → MERGE broken → tìm nguyên nhân.

**C2. Flow 04 — unique_row_id collision risk**
```sql
unique_row_id = md5(
  COALESCE(CAST(VendorID AS text), '') ||
  COALESCE(CAST(tpep_pickup_datetime AS text), '') ||
  COALESCE(CAST(tpep_dropoff_datetime AS text), '') ||
  COALESCE(PULocationID, '') ||
  COALESCE(DOLocationID, '') ||
  COALESCE(CAST(fare_amount AS text), '') ||
  COALESCE(CAST(trip_distance AS text), '')
)
```
- Nếu 2 chuyến có cùng vendor, cùng pickup/dropoff time, cùng location và fare → cùng hash → MERGE chỉ insert 1 row.
  Đây là bug hay acceptable tradeoff? Ghi nhận.
- Có unique constraint/index nào trên cột `unique_row_id` không?
  ```sql
  SELECT COUNT(*), COUNT(DISTINCT unique_row_id) FROM public.yellow_tripdata;
  ```
  Hai con số này có khớp không?

**C3. Flow 04 — pluginDefaults credentials**
```yaml
pluginDefaults:
  - type: io.kestra.plugin.jdbc.postgresql
    values:
      url: jdbc:postgresql://pgdatabase:5432/ny_taxi
      username: root
      password: root
```
- `root/root` hardcode trong flow YAML — nếu flow YAML được commit lên Git public → credentials bị lộ.
- Hostname `pgdatabase` — chỉ resolve được từ trong Docker network. Chạy từ ngoài Docker sẽ fail.
- Ghi nhận: đây là dev-only config, không phải production pattern.

**C4. Flow 04 — Variable expression edge case**
```yaml
data: "{{outputs.extract.outputFiles[inputs.taxi ~ '_' ~ 'tripdata_' ~ inputs.year ~ '-' ~ inputs.month ~ '.csv']}}"
```
- Expression concatenation dùng Pebble `~` operator — verify syntax đúng.
- Nếu `inputs.taxi = yellow`, `inputs.year = 2019`, `inputs.month = 01` → key phải là `yellow_tripdata_2019-01.csv`.
- Kiểm tra: output file từ shell task có đúng tên này không?

**C5. Flow 05 — Scheduled trigger logic**
- Hai triggers `green_schedule` (09:00) và `yellow_schedule` (10:00) cùng `cron: "0 X 1 * *"` (ngày 1 mỗi tháng).
- `concurrency: limit: 1` — nếu green đang chạy lúc 09:00 và yellow trigger lúc 10:00 → yellow có bị QUEUE hay FAIL?
- `trigger.date` trong variable expression: khi backfill tháng 2019-01, `trigger.date` có đúng là `2019-01-01` không?
- Backfill có thể chạy cả green lẫn yellow song song không? Có race condition trên staging table không?
  (green và yellow dùng CÙNG staging table pattern `public.yellow_tripdata_staging` vs `public.green_tripdata_staging` — verify tên staging table khác nhau.)

**C6. Data verification queries — chạy trong pgAdmin**
```sql
-- Kiểm tra tables tồn tại
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY table_name;

-- Row counts
SELECT 'yellow' as taxi, COUNT(*) as rows FROM public.yellow_tripdata
UNION ALL
SELECT 'green', COUNT(*) FROM public.green_tripdata;

-- Duplicate check
SELECT COUNT(*) total, COUNT(DISTINCT unique_row_id) unique_ids
FROM public.yellow_tripdata;

-- Sample data
SELECT unique_row_id, filename, VendorID, tpep_pickup_datetime, total_amount
FROM public.yellow_tripdata LIMIT 5;

-- Null unique_row_id check
SELECT COUNT(*) FROM public.yellow_tripdata WHERE unique_row_id IS NULL;
```

---

### ════════════════════════════════
### BLOCK D — GCP ELT (flows 06–09)
### ════════════════════════════════

**D1. Flow 06 — KV placeholder values**
- File gốc có placeholder chưa đổi:
  ```yaml
  value: kestra-sandbox  # TODO replace with your project id
  value: your-name-kestra  # TODO make sure it's globally unique!
  ```
- Confirm đã replace đúng GCP_PROJECT_ID và GCP_BUCKET_NAME trước khi execute flow 07.
- Kiểm tra KV store sau khi chạy flow 06:
  Kestra UI → Settings → KV Store → namespace `zoomcamp` → 4 keys phải có:
  `GCP_PROJECT_ID`, `GCP_LOCATION`, `GCP_BUCKET_NAME`, `GCP_DATASET`

**D2. Flow 07 — Infrastructure idempotency**
- `ifExists: SKIP` cho cả bucket lẫn dataset — chạy flow 07 lần 2 không được báo lỗi.
- Verify trên GCP Console: bucket và dataset exist với đúng location.
- `storageClass: REGIONAL` cho bucket — location phải match `GCP_LOCATION` trong KV.

**D3. Flow 08 — GCS variable expression bug tiềm ẩn**
```yaml
gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{vars.file}}"
```
- Dùng `{{vars.file}}` thay vì `{{render(vars.file)}}` — trong Kestra, `vars.file` có được render nested expression không?
  `vars.file = "{{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv"` (chứa expression bên trong).
- Nếu không render → GCS path sẽ là `gs://bucket/{{inputs.taxi}}_tripdata_...` (literal).
- So sánh với flow 04 dùng `{{render(vars.file)}}` nhất quán — flow 08 có thể có bug.
- **Test**: sau khi upload, kiểm tra GCS object path thực tế trong Console có đúng không.

**D4. Flow 08 — unique_row_id type mismatch**
- Postgres (flow 04): `unique_row_id text` → dùng `md5()` trả về hex string.
- BigQuery (flow 08): `unique_row_id BYTES` → dùng `MD5()` trả về BYTES.
- Đây là inconsistency giữa hai pipeline. Không phải bug trong từng flow riêng lẻ, nhưng nếu muốn join cross-system sẽ cần cast.
- Ghi nhận để awareness.

**D5. Flow 08 — Green unique_row_id thiếu cột so với Yellow**
Yellow hash dùng 7 cột:
```sql
MD5(CONCAT(VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
           PULocationID, DOLocationID, fare_amount, trip_distance))
```
Green hash chỉ dùng 5 cột:
```sql
MD5(CONCAT(VendorID, lpep_pickup_datetime, lpep_dropoff_datetime,
           PULocationID, DOLocationID))
-- fare_amount và trip_distance bị bỏ qua!
```
- Green có collision risk cao hơn Yellow → duplicate rows có thể bị bỏ qua khi merge.
- Ghi nhận: inconsistency trong hash logic giữa 2 taxi types.

**D6. Flow 08 — idempotency check GCP**
- Execute flow 08 với `yellow/2019/01` → ghi BQ row count.
- Execute lại → row count phải KHÔNG thay đổi.
- Kiểm tra trong BQ Console:
  ```sql
  SELECT COUNT(*) FROM `<project>.zoomcamp.yellow_tripdata`
  WHERE filename = 'yellow_tripdata_2019-01.csv';
  ```

**D7. Flow 09 — trigger.date variable trong gcs_file**
```yaml
gcs_file: "gs://{{kv('GCP_BUCKET_NAME')}}/{{vars.file}}"
```
- Cùng vấn đề như D3 — `{{vars.file}}` chứa `{{trigger.date | date('yyyy-MM')}}` bên trong.
- Khi chạy scheduled, `trigger.date` có available trong nested render không?
- **Test**: kiểm tra GCS path sau khi scheduled trigger chạy.

**D8. Flow 09 — backfill concurrency**
- Khi backfill 2019-01 → 2020-12 (24 tháng × 2 taxi = 48 executions):
  - Không có `concurrency` limit trong flow 09 → có thể chạy song song nhiều executions.
  - Race condition trên BQ main table (`yellow_tripdata`) khi nhiều MERGE cùng lúc?
  - GCP BigQuery có handle concurrent MERGE safely không?

---

### ════════════════════════════════
### BLOCK E — SECURITY AUDIT
### ════════════════════════════════

**E1. Credentials inventory — liệt kê đầy đủ**

| Credential | Location | Hardcode? | Risk |
|---|---|---|---|
| Postgres ny_taxi root/root | docker-compose.yml + pluginDefaults flow 04/05 | YES | Medium (local only) |
| Kestra basic auth admin/Admin1234! | docker-compose.yml | YES | Medium |
| Kestra metadata DB kestra/k3str4 | docker-compose.yml | YES | Low (internal only) |
| GCP service account JSON | Kestra Secret store | NO (secret) | Low nếu secret đúng |
| Gemini API key | Kestra KV store | NO (kv) | Medium (KV ít bảo mật hơn Secret) |

**E2. Secret vs KV store — phân biệt**
- `secret('GCP_CREDS')` → encrypted, không hiện trong UI/logs.
- `kv('GEMINI_API_KEY')` → KV store, ít bảo mật hơn, có thể xem trong Settings UI.
- Gemini API key nên để trong Secret, không phải KV. Ghi nhận.

**E3. Kestra user: root**
```yaml
user: "root"
```
- Kestra container chạy với root user để access Docker socket.
- Comment trong file thừa nhận đây là dev-only: "this setup with a root user is intended for development purpose."
- Production cần rootless mode (Podman Compose).

---

### ════════════════════════════════
### BLOCK F — FLOW DESIGN REVIEW
### ════════════════════════════════

**F1. DRY violations — đo độ lặp lại**
Các đoạn SQL schema lặp giữa các flows:
- Yellow CREATE TABLE: xuất hiện ở flow 04, 05, 08, 09 → 4 lần
- Green CREATE TABLE: xuất hiện ở flow 04, 05, 08, 09 → 4 lần
- wget download command: flow 04, 05, 08, 09 → 4 lần
- MERGE statement: flow 04, 05, 08, 09 → 4 lần (8 nếu tính cả yellow + green)

Câu hỏi: Kestra có subflow/template mechanism để giảm duplication không?
Repo có dùng không? Nếu không → technical debt.

**F2. Error handling gaps — kiểm tra từng flow**
- Không có `retry` policy trên bất kỳ task nào → wget fail do network → toàn flow fail không retry.
- Không có `onFailure` task branch → không có cleanup/alert khi fail.
- Không có `timeout` trên tasks → wget có thể hang vô thời hạn.
- Kiểm tra: nếu disable internet access → flow fail ở task nào? Message lỗi có rõ ràng không?

**F3. purge_files placement**
- `purge_files` là task cuối trong flow → nếu task trước fail, purge không chạy → storage bị tích lũy.
- Correct pattern: purge nên chạy trong finally/cleanup block.
- Kestra có `finally` task concept không?

**F4. Input validation gaps**
- Flow 04/08 có `allowCustomValue: true` trên year input → user có thể nhập `2021`, `2022`, `abc`.
- Nếu nhập năm không có data trên GitHub releases → wget sẽ download file rỗng/404.
- Không có pre-validation task kiểm tra file tồn tại trước khi load vào DB/GCS.

---

### ════════════════════════════════
### BLOCK G — PERFORMANCE & SCALABILITY
### ════════════════════════════════

**G1. Download performance**
- `wget` không có parallel download, không có checksum verify.
- File `yellow_tripdata_2019-01.csv.gz` ~ 130MB compressed → unzip tốn bao lâu trong task?
- Đo thực tế: execution time của task `extract` trong Kestra logs.

**G2. Postgres COPY vs INSERT performance**
- `CopyIn` dùng PostgreSQL COPY protocol → nhanh hơn INSERT nhiều.
- Confirm: task `yellow_copy_in_to_staging_table` sử dụng `CopyIn` type đúng không?

**G3. BigQuery partition effectiveness**
- Yellow table: `PARTITION BY DATE(tpep_pickup_datetime)`.
- Green table: `PARTITION BY DATE(lpep_pickup_datetime)`.
- Khi MERGE monthly data vào, chỉ partition của tháng đó bị scan → đúng pattern.
- Verify: query plan trong BQ Console có dùng partition pruning không?

---

### ════════════════════════════════
### BLOCK H — END-TO-END SMOKE TEST
### ════════════════════════════════

Chạy theo thứ tự, ghi kết quả:

```
□ H1. docker compose up -d → tất cả services UP
□ H2. Flow 01 execute name="ReviewTest" → logs hiện, sleep 15s, output generated
□ H3. Flow 02 execute → output downloads là số > 0
□ H4. Flow 03 execute columns=["brand","price"] → DuckDB query trả về avg_price
□ H5. Flow 04 yellow/2019/01 → Postgres table tồn tại, rows > 0
□ H6. Flow 04 yellow/2019/01 lại → rows KHÔNG đổi (idempotency)
□ H7. Flow 04 green/2019/01 → green table tồn tại
□ H8. Flow 06 execute → 4 KV keys xuất hiện trong KV Store
□ H9. Flow 07 execute → GCS bucket + BQ dataset tồn tại trên GCP Console
□ H10. Flow 08 yellow/2019/01 → GCS object exist + BQ yellow_tripdata có rows
□ H11. Flow 08 yellow/2019/01 lại → BQ row count KHÔNG đổi (idempotency)
□ H12. Flow 08 green/2019/01 → GCS object exist + BQ green_tripdata có rows
```

---

## OUTPUT FORMAT YÊU CẦU

Sau khi review xong, trả lời theo format sau để dùng làm input cho PROMPT_Patch_After_Review:

```
## REVIEW SUMMARY — MODULE 02

### ✅ PASSED (không cần fix)
- [A1] Services startup: OK, thứ tự đúng
- [H5] Idempotency Postgres: OK
- ...

### ⚠️ WARNING (nên fix, không block)
- [C2] unique_row_id collision risk: MD5 của 7 cột có thể collide nếu data trùng
  → Suggestion: thêm UNIQUE CONSTRAINT hoặc log duplicate count sau MERGE
- [D5] Green hash dùng ít cột hơn Yellow: inconsistency
  → Suggestion: thêm fare_amount + trip_distance vào green hash
- ...

### ❌ BUG (phải fix trước dùng)
- [D3] gcs_file variable không render nested expression:
  Actual path: gs://bucket/{{inputs.taxi}}_tripdata_...
  Expected path: gs://bucket/yellow_tripdata_2019-01.csv
  → Fix: đổi {{vars.file}} thành {{render(vars.file)}} trong flow 08 và 09
- ...

### 📋 TECH DEBT (ghi nhận, fix sau)
- [F1] SQL schema lặp 4 lần mỗi loại → refactor thành subflow nếu Kestra support
- [F2] Không có retry/timeout trên wget tasks
- [E2] Gemini API key nên dùng Secret thay vì KV
- ...
```

---

## LƯU Ý QUAN TRỌNG

1. **Ưu tiên review D3/D7 trước** — bug `{{vars.file}}` vs `{{render(vars.file)}}` có thể làm toàn bộ GCS upload sai path mà không báo lỗi rõ ràng.
2. **Chạy idempotency test (H6, H11) bắt buộc** — đây là core guarantee của pipeline.
3. **Block C6 queries phải chạy thực tế** — không đoán, xem số liệu thật.
4. **Flows 10/11 (AI/RAG) không nằm trong scope review này** — review riêng nếu cần.
