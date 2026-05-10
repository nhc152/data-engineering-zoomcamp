# Python cho Data Pipeline

## Vai tro cua Python trong Data Engineering 2026

Python la ngon ngu keo noi giua source system, storage, warehouse, orchestrator va quality checks. Trong Data Engineering, Python khong phai chi de notebook hay data analysis. Python duoc dung de viet nhung thanh phan pipeline co kha nang chay lai, log duoc, test duoc va van hanh duoc.

Trong mot stack hien dai, Python thuong xuat hien o cac vi tri:

- Extract data tu REST API, SFTP, object storage, database.
- Parse JSON, CSV, XML, log files.
- Luu raw data truoc khi transform.
- Batch load vao PostgreSQL, BigQuery, Snowflake, S3/GCS.
- Viet task trong Airflow/Kestra/Dagster.
- Viet validation, reconciliation, audit scripts.
- Viet utility cho backfill, replay, migration, repair data.
- Dong goi pipeline thanh Docker image.

Neu ban da quen ODI/Talend, hay xem Python nhu cach viet mapping va job control bang code. Diem khac biet la Python bat ban tu thiet ke idempotency, logging, config, retry, error handling va test ro rang hon.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Viet Python pipeline extract-load-transform co cau truc.
- Goi API co pagination, timeout, retry/backoff.
- Doc/ghi CSV, JSON, JSONL va Parquet o muc co ban.
- Xu ly malformed JSON, missing field, schema drift.
- Quan ly config bang environment variables va file config.
- Viet logging dung cho production debugging.
- Viet code idempotent: chay lai khong tao duplicate.
- Tach project thanh module, khong viet tat ca trong mot script.
- Viet test co ban cho transform va validation logic.
- Dong goi pipeline de chay trong Docker/orchestrator.
- Giai thich trade-off giua pandas, Polars, plain Python, Spark va SQL.

## Khai niem can nam

Nen nam vung:

- Function, module, package.
- Virtual environment.
- Dependency management.
- File I/O.
- CSV, JSON, JSONL, Parquet.
- HTTP client.
- Timeout.
- Retry/backoff.
- Exception handling.
- Logging.
- Environment variables.
- Config object.
- Type hints.
- Dataclass/Pydantic concept.
- Batch processing.
- Idempotency.
- Checkpoint/watermark.
- Unit test va integration test.

## Learning roadmap

### Giai doan 1: Beginner

Muc tieu: viet script doc file, clean nhe, ghi output.

Can lam:

- Doc CSV/JSON.
- Validate required columns.
- Ghi file output.
- Chay script tu command line.

Vi du command:

```bash
python -m src.pipeline --run-date 2026-05-01
```

### Giai doan 2: Implement

Muc tieu: viet pipeline API -> raw file -> normalized records -> database.

Can lam:

- Goi API voi timeout.
- Xu ly pagination.
- Luu raw response.
- Normalize nested JSON.
- Load vao PostgreSQL.
- Log row count.

### Giai doan 3: Productionize

Muc tieu: pipeline chay lai duoc, co config, retry, logging, test.

Can lam:

- Dung `.env` va environment variables.
- Khong hard-code secret.
- Retry loi tam thoi.
- Fail fast khi data sai.
- Them idempotent load.
- Them unit tests.

### Giai doan 4: Debug

Muc tieu: tim root cause khi pipeline fail hoac data sai.

Can lam:

- Debug malformed JSON.
- Debug API rate limit.
- Debug duplicate rows.
- Debug null/missing fields.
- Debug encoding/timezone.
- Debug partial load.

### Giai doan 5: Optimize

Muc tieu: giam memory, tang throughput, giam chi phi.

Can lam:

- Batch insert thay vi insert tung row.
- Stream JSONL thay vi load ca file lon vao memory.
- Dung Parquet cho analytical data.
- Dung chunking.
- Dung database/warehouse cho transform lon thay vi pandas.

### Giai doan 6: Interview

Muc tieu: giai thich duoc pipeline design va failure handling.

Can tra loi:

- Pipeline co idempotent khong?
- Retry co gay duplicate khong?
- Neu API tra malformed JSON thi sao?
- Neu load fail giua chung thi sao?
- Neu source gui late data thi sao?
- Neu data tang 100 lan thi doi gi?

## Python project structure

Mot project pipeline nen co cau truc:

```text
data-pipeline/
  README.md
  pyproject.toml
  .env.example
  src/
    pipeline/
      __init__.py
      config.py
      extract.py
      normalize.py
      load.py
      quality.py
      logging_config.py
      main.py
  tests/
    test_normalize.py
    test_quality.py
  data/
    raw/
    processed/
```

Y nghia:

- `config.py`: doc config, validate environment.
- `extract.py`: noi chuyen voi source system.
- `normalize.py`: convert raw data thanh records/table shape.
- `load.py`: ghi vao file/database/warehouse.
- `quality.py`: validation va reconciliation.
- `main.py`: orchestration nho trong process.

Khong nen de 500 dong trong `script.py`. Khi pipeline fail, code khong tach module se rat kho test va kho debug.

## Config management

Config production nen tach khoi code:

- Database host.
- API base URL.
- API token.
- Batch size.
- Timeout.
- Retry count.
- Run date.
- Output path.

Vi du:

```python
from dataclasses import dataclass
import os


@dataclass(frozen=True)
class PipelineConfig:
    api_base_url: str
    api_token: str
    output_dir: str
    batch_size: int
    request_timeout_seconds: int


def load_config() -> PipelineConfig:
    return PipelineConfig(
        api_base_url=os.environ["API_BASE_URL"],
        api_token=os.environ["API_TOKEN"],
        output_dir=os.environ.get("OUTPUT_DIR", "data/raw"),
        batch_size=int(os.environ.get("BATCH_SIZE", "1000")),
        request_timeout_seconds=int(os.environ.get("REQUEST_TIMEOUT_SECONDS", "30")),
    )
```

Kinh nghiem:

- Secret nam trong env/secret manager, khong nam trong Git.
- `.env.example` chi chua key mau, khong co token that.
- Config nen fail som neu thieu bien bat buoc.

## File handling

### CSV

CSV de doc, nhung co nhieu loi thuc te:

- Comma trong text.
- Encoding khac UTF-8.
- Header thay doi.
- Empty string vs NULL.
- Date format khong nhat quan.

Khi ingest CSV:

- Luu raw file truoc.
- Validate header.
- Log row count.
- Ghi rejected rows neu parse fail.

### JSON va JSONL

JSON phu hop API response nho. JSONL phu hop event/record streaming vi moi dong la mot JSON object.

JSONL co loi the:

- Doc tung dong.
- File lon van xu ly duoc.
- Record loi co the isolate.

Vi du doc JSONL an toan:

```python
import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


def read_jsonl(path: Path) -> list[dict]:
    records: list[dict] = []
    bad_lines = 0

    with path.open("r", encoding="utf-8") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError:
                bad_lines += 1
                logger.exception("malformed_json_line", extra={"line_number": line_number})

    if bad_lines > 0:
        raise ValueError(f"Found {bad_lines} malformed JSON lines in {path}")

    return records
```

### Parquet

Parquet nen dung cho analytical data:

- Columnar.
- Compression tot.
- Giu schema tot hon CSV.
- Phu hop BigQuery/Spark/warehouse.

Trade-off:

- Khong de doc bang text editor.
- Can dependency nhu pyarrow.
- Schema evolution can quan ly can than.

## API ingestion patterns

### Timeout la bat buoc

Request khong timeout co the treo pipeline.

```python
import requests


def fetch_page(url: str, token: str, timeout_seconds: int = 30) -> dict:
    response = requests.get(
        url,
        headers={"Authorization": f"Bearer {token}"},
        timeout=timeout_seconds,
    )
    response.raise_for_status()
    return response.json()
```

### Pagination

Nhieu API khong tra het data trong mot request.

Pattern:

```python
def fetch_all_pages(base_url: str, token: str) -> list[dict]:
    records: list[dict] = []
    next_url: str | None = base_url

    while next_url:
        payload = fetch_page(next_url, token)
        records.extend(payload.get("data", []))
        next_url = payload.get("next_page_url")

    return records
```

Can log:

- Page number.
- Records per page.
- Total records.
- Status code.
- Rate limit remaining neu API co header.

### Retry va backoff

Retry chi nen dung cho loi tam thoi:

- Timeout.
- 429 rate limit.
- 500/502/503/504.
- Network reset.

Khong retry vo toi va:

- 400 bad request.
- 401 unauthorized.
- 403 forbidden.
- Data validation error.

Vi du conceptual:

```python
import time
import requests


RETRYABLE_STATUS_CODES = {429, 500, 502, 503, 504}


def fetch_with_retry(url: str, token: str, max_attempts: int = 3) -> dict:
    for attempt in range(1, max_attempts + 1):
        try:
            response = requests.get(
                url,
                headers={"Authorization": f"Bearer {token}"},
                timeout=30,
            )

            if response.status_code in RETRYABLE_STATUS_CODES:
                raise requests.HTTPError(f"retryable_status={response.status_code}")

            response.raise_for_status()
            return response.json()

        except (requests.Timeout, requests.ConnectionError, requests.HTTPError):
            if attempt == max_attempts:
                raise
            sleep_seconds = 2 ** attempt
            time.sleep(sleep_seconds)

    raise RuntimeError("unreachable")
```

Production notes:

- Dung library nhu `tenacity` khi project cho phep.
- Log attempt number.
- Respect `Retry-After` header neu co.
- Retry load step phai idempotent, neu khong se tao duplicate.

## Error handling

### Loi nen fail fast

- Missing required field.
- Schema khong dung.
- Primary key NULL.
- Credential sai.
- Business rule bi vi pham nghiem trong.

### Loi co the isolate

- Mot vai malformed records.
- Mot vai row sai type.
- Mot vai optional field thieu.

Pattern:

- Luu rejected records rieng.
- Log reason.
- Dat threshold. Vi du neu rejected > 1% thi fail job.

```python
def validate_order(record: dict) -> tuple[bool, str | None]:
    if not record.get("order_id"):
        return False, "missing_order_id"
    if not record.get("customer_id"):
        return False, "missing_customer_id"
    if record.get("amount") is not None and record["amount"] < 0:
        return False, "negative_amount"
    return True, None
```

## Logging production

Logging khong phai `print("done")`. Log phai giup tra loi:

- Job nao chay?
- Run date nao?
- Source nao?
- Extract bao nhieu rows?
- Load bao nhieu rows?
- Fail o buoc nao?
- Error co retry khong?
- Duration bao lau?

Vi du:

```python
import logging

logger = logging.getLogger(__name__)


def load_orders(records: list[dict]) -> int:
    logger.info("load_orders_started", extra={"record_count": len(records)})
    loaded_count = 0

    for record in records:
        # insert/upsert here
        loaded_count += 1

    logger.info("load_orders_finished", extra={"loaded_count": loaded_count})
    return loaded_count
```

Kinh nghiem:

- Log structured fields neu co the.
- Log count, duration, key parameters.
- Khong log secret/token.
- Khong swallow exception roi return success.

## Idempotency va duplicate prevention

Idempotency nghia la chay lai cung input se khong lam sai output.

### Bad pipeline

```python
def bad_load(conn, records):
    for record in records:
        conn.execute(
            "insert into orders(order_id, amount) values (%s, %s)",
            (record["order_id"], record["amount"]),
        )
```

Neu job fail sau 500/1000 rows va chay lai, 500 rows dau co the duplicate.

### Better pattern

- Dat unique constraint.
- Load vao staging table.
- Merge/upsert vao target.
- Ghi `run_id`, `ingested_at`.
- Dung transaction.

PostgreSQL upsert concept:

```sql
insert into orders(order_id, customer_id, amount, updated_at)
values (%s, %s, %s, %s)
on conflict (order_id) do update set
    customer_id = excluded.customer_id,
    amount = excluded.amount,
    updated_at = excluded.updated_at;
```

### Batch processing mindset

Moi batch nen co:

- `run_id`
- `run_date`
- `source_name`
- `extracted_count`
- `loaded_count`
- `rejected_count`
- `started_at`
- `finished_at`
- `status`

Audit table giup debug pipeline sau nay.

## Testing basics

Nen test logic thuan truoc:

```python
def normalize_status(status: str | None) -> str:
    if status is None:
        return "unknown"
    return status.strip().lower()
```

Test:

```python
def test_normalize_status():
    assert normalize_status(" PAID ") == "paid"
    assert normalize_status(None) == "unknown"
```

Nen test:

- Normalize status.
- Parse timestamp.
- Validate required fields.
- Deduplicate rule.
- Mapping business rule.

Integration test co the chay voi Postgres Docker sau.

## Architecture mindset

### Pipeline nho

```text
API -> Python extract -> raw JSONL -> normalize -> PostgreSQL staging -> SQL marts
```

Phu hop:

- Dataset nho/vua.
- Team moi bat dau.
- Can hoc end-to-end.

### Pipeline cloud

```text
API -> Python extract -> GCS/S3 raw -> BigQuery/Snowflake external/load -> dbt models -> quality checks
```

Phu hop:

- Muon giu raw history.
- Query analytical tren warehouse.
- Can backfill.

### Khi nao khong nen dung Python transform

Khong nen dua transform lon vao pandas neu:

- Data qua memory local.
- Transform chu yeu la join/aggregate SQL.
- Warehouse co the xu ly tot hon.
- Can lineage/test trong dbt.

Python nen lam extract/load/control; SQL/dbt nen lam transformation analytical; Spark nen lam batch distributed lon.

## Real-world debugging

### Malformed JSON

Trieu chung:

- `JSONDecodeError`.
- Job fail giua file.
- Source tra HTML error page thay vi JSON.

Debug:

1. Log status code va content-type.
2. Luu raw response khi fail.
3. In first 500 chars cua response, khong in token.
4. Kiem tra API co rate limit/login redirect khong.
5. Tach bad line neu JSONL.

### Duplicate records

Trieu chung:

- Row count target tang gap doi sau retry.
- Revenue bi double.

Debug:

1. Kiem tra unique key.
2. Kiem tra job co append hay upsert.
3. Kiem tra retry co load lai partial batch.
4. Kiem tra source co duplicate khong.
5. Kiem tra merge key co dung grain khong.

### Missing data

Trieu chung:

- Source co 10k rows, target co 8k rows.

Debug:

1. Log count tung page API.
2. Kiem tra pagination stopping condition.
3. Kiem tra filter run_date/timezone.
4. Kiem tra rejected records.
5. Kiem tra transaction rollback/commit.

### Timezone bug

Trieu chung:

- Report ngay bi lech 1 ngay.
- Backfill ngay cu thieu/du.

Debug:

1. Source timestamp timezone nao?
2. Pipeline parse aware hay naive datetime?
3. Warehouse luu UTC hay local?
4. Business date tinh theo timezone nao?

## Real-world failure cases

### API rate limit

Nguyen nhan:

- Chay backfill qua nhanh.
- Khong respect rate limit.

Fix:

- Exponential backoff.
- Respect `Retry-After`.
- Limit concurrency.
- Cache raw response.

### Partial load

Nguyen nhan:

- Insert tung row, fail giua chung.
- Khong transaction.

Fix:

- Load staging.
- Transaction.
- Upsert.
- Audit batch.

### Schema drift

Nguyen nhan:

- Source them/xoa/doi ten field.

Fix:

- Validate schema.
- Alert khi missing required fields.
- Cho phep optional fields.
- Version raw data.

### Memory blow-up

Nguyen nhan:

- Load file lon vao pandas mot lan.

Fix:

- Chunking.
- JSONL streaming.
- Push transform vao SQL/Spark.
- Ghi intermediate Parquet.

## Trade-offs

- Plain Python: it dependency, tot cho utility nho, nhung verbose cho dataframes.
- pandas: nhanh de prototype, tot cho data nho/vua, khong tot cho data lon hon memory.
- Polars: nhanh, memory efficient hon pandas trong nhieu case, nhung ecosystem it quen hon.
- Spark: scale lon, nhung overhead cao, debug phuc tap.
- SQL warehouse: tot cho join/aggregate analytical, nhung khong phu hop goi API/file control.
- Airflow/Kestra task Python: tot de orchestration, nhung khong nen nhung business transform phuc tap vao DAG code.

## Performance considerations

- Dung batch insert thay vi insert tung row.
- Dung COPY/Postgres bulk load neu load CSV lon.
- Chunk file lon.
- Nen luu raw compressed.
- Tranh convert date/string lap lai trong loop neu co the vectorize.
- Khong dung pandas neu data vuot memory.
- Do duration tung step: extract, parse, load, validate.
- Giam API calls thua bang incremental watermark.

## Hands-on exercises

### Level 1: File pipeline

1. Doc `orders.csv`.
2. Validate required columns.
3. Normalize status casing.
4. Ghi `orders_clean.jsonl`.
5. Log input/output row count.

### Level 2: API ingestion

1. Goi API public co pagination.
2. Set timeout.
3. Luu raw JSON theo `run_date`.
4. Normalize nested JSON.
5. Ghi JSONL.

### Level 3: Database load

1. Tao PostgreSQL table co unique key.
2. Load records vao staging.
3. Upsert vao target.
4. Chay lai job va chung minh khong duplicate.

### Level 4: Debugging

1. Tao 5 records malformed JSON.
2. Tao duplicate order_id.
3. Tao missing customer_id.
4. Viet rejected records file.
5. Fail job neu rejected ratio > 1%.

### Level 5: Productionization

1. Them `.env.example`.
2. Them config dataclass.
3. Them structured logging.
4. Them retry/backoff.
5. Them pytest cho normalize/validate.

## Mini project

### De bai

Build pipeline:

```text
Public API -> raw JSONL -> normalized orders -> PostgreSQL staging -> upsert target -> quality report
```

### Yeu cau

- Co `run_id`.
- Co `run_date`.
- Co raw file.
- Co rejected records.
- Co upsert idempotent.
- Co log row count.
- Co test cho normalize va validation.
- README co architecture va failure handling.

### Folder goi y

```text
python-pipeline/
  src/pipeline/
    config.py
    extract.py
    normalize.py
    load.py
    quality.py
    main.py
  tests/
  sql/
  data/raw/
  data/rejected/
  README.md
  .env.example
```

## Kinh nghiem thuc te

- Raw data la bao hiem. Neu transform sai, co raw moi reprocess duoc.
- Retry phai di kem idempotency. Retry ma append mu quang se tao duplicate.
- Log count quan trong hon log "success".
- Code pipeline nen de nguoi khac chay lai bang 1-2 command.
- Parse timestamp/timezone phai quy chuan tu dau.
- Bad records nen duoc ghi lai, khong nen mat im lang.
- Moi pipeline nen co audit table hoac audit file.

## Loi thuong gap

- Hard-code path, token, database password.
- Khong timeout API request.
- Khong xu ly pagination.
- Khong xu ly 429 rate limit.
- Swallow exception va van return success.
- Append moi lan chay gay duplicate.
- Dung pandas cho data qua lon.
- Khong luu raw data.
- Khong log row count tung step.
- Code chay local nhung fail trong Docker vi path/env khac.

## Cau hoi phong van

### API va ingestion

- Ban thiet ke pipeline ingest REST API nhu the nao?
- Xu ly pagination ra sao?
- Xu ly rate limit ra sao?
- Khi nao retry, khi nao khong retry?
- Neu API tra malformed JSON thi debug the nao?

### Reliability

- Idempotency la gi?
- Lam sao tranh duplicate khi job retry?
- Neu load fail giua chung thi xu ly sao?
- Audit table nen chua nhung cot nao?
- Raw data layer co vai tro gi?

### Python engineering

- Vi sao can config/env variables?
- Logging production nen log gi?
- Unit test trong data pipeline nen test gi?
- Type hints giup gi?
- Khi nao dung pandas, khi nao dung Spark?

### Performance

- Vi sao insert tung row cham?
- Khi nao dung batch insert/COPY?
- Xu ly file lon hon memory ra sao?
- JSON, JSONL, Parquet khac nhau nhu the nao trong pipeline?

## Dau ra can co tren GitHub

Toi thieu:

- `src/` co module tach ro.
- `.env.example`.
- `README.md` co architecture va run command.
- `requirements.txt` hoac `pyproject.toml`.
- `tests/` co test cho normalize/validate.
- Script chay duoc tu CLI.

Tot hon:

- Dockerfile.
- PostgreSQL schema.
- Audit table.
- Raw/rejected sample files nho.
- CI chay pytest.
- README co "failure handling" va "idempotency strategy".

## Production upgrade: packaging, CLI va failure lab

### Project skeleton production

Mot Python ingestion repo nen co cau truc ro de test, package va chay trong Docker/orchestrator:

```text
pyproject.toml
src/
  de_pipeline/
    __init__.py
    cli.py
    config.py
    extract.py
    load.py
    logging.py
    retry.py
tests/
  unit/
  integration/
.env.example
```

`pyproject.toml` nen khai bao dependencies, formatter/linter va test tools. Toi thieu nen co:

- `ruff` cho lint/format.
- `pytest` cho tests.
- `mypy` neu codebase bat dau lon va co contract ro.
- pinned dependency versions de build reproducible.

### CLI design

Pipeline production khong nen chi chay bang hard-code trong `main.py`. Can CLI:

```bash
python -m de_pipeline.cli ingest-orders --run-date 2026-05-09 --source api --mode incremental
```

CLI tot giup:

- Orchestrator truyen parameter ro.
- Backfill theo ngay.
- Debug local giong production.
- Log command va arguments vao audit table.

### Retry with jitter va rate-limit budget

Retry API can co jitter de tranh nhieu worker retry cung luc.

Bad pattern:

```text
retry every 5 seconds for all tasks
```

Production pattern:

```text
exponential backoff + random jitter + max retry + max elapsed time
```

Rate-limit budget:

- Biet API cho bao nhieu requests/minute.
- Gioi han concurrency.
- Log remaining quota neu API tra header.
- Khi gan het quota, slow down thay vi spam retry.

### Sync vs async ingestion

Sync:

- Don gian.
- De debug.
- Tot cho API nho/vua.

Async:

- Tot khi co nhieu HTTP calls I/O-bound.
- Can rate limit, timeout, cancellation, error aggregation.
- Kho debug hon neu developer chua vung.

Rule:

- Bat dau sync + batching + retry dung.
- Chi chuyen async khi bottleneck thuc su la I/O latency va co monitoring.

### Connection pooling va batch size

Database load cham thuong do:

- Insert tung row.
- Mo connection moi moi batch.
- Batch qua lon gay lock/memory.
- Batch qua nho overhead cao.

Production habit:

- Dung connection pool neu app chay lau.
- Bulk load/copy neu database ho tro.
- Tune batch size bang measurement.
- Commit theo batch co audit row count.

### Failure lab

#### Case 1: pagination mat data

Symptom:

- API report 10,000 records, warehouse chi co 9,500.

Diagnostics:

1. Log page number, cursor, count per page.
2. Check termination condition.
3. Check duplicate/missing IDs by source primary key.
4. Re-run same date with raw response saved.

Prevention:

- Persist raw pages.
- Store cursor checkpoints.
- Assert total count if API provides it.

#### Case 2: partial file write

Symptom:

- Downstream reads file dang ghi do, parse fail hoac row count thieu.

Fix:

- Write to temp path.
- Validate checksum/row count.
- Atomic rename/move to final path.
- Add `_SUCCESS` marker neu data lake pattern can.

#### Case 3: pandas memory blowup

Symptom:

- Script local ok voi sample, fail OOM voi production file.

Fix:

- Read chunks.
- Select needed columns.
- Use streaming JSON parser.
- Use Polars/Spark/warehouse load job neu data lon.

#### Case 4: duplicate retry

Symptom:

- Task timeout after load succeeded, retry inserts same rows again.

Fix:

- Use staging table + merge.
- Add unique constraint.
- Track batch_id/run_id.
- Make load idempotent before enabling retry.
