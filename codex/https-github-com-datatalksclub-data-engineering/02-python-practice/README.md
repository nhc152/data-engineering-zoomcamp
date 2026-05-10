# Python Practice Lab

Production-style Python ingestion lab for Data Engineering 2026.

This lab is built for a learner transitioning from GUI ETL tools such as ODI/Talend to code-based Python pipelines.

## Goal

Build and debug a local ingestion pipeline:

```text
CSV / JSON / JSONL / simulated API
    -> Python extract
    -> raw JSONL copy
    -> transform and validation
    -> rejected records
    -> idempotent PostgreSQL upsert
    -> audit table
```

## What This Lab Teaches

- CSV ingestion.
- JSON and JSONL ingestion.
- Simulated paginated API ingestion.
- Config via `.env`.
- Structured JSON logging.
- Retry with exponential backoff and jitter.
- Pagination.
- Rate limit and timeout handling.
- Raw file write before transform.
- Validation.
- Rejected records.
- Idempotent load into PostgreSQL.
- Pytest unit tests.
- Broken ingestion scenarios.

## Architecture

```text
data/sample/*
    |
    v
src/extract.py
    |
    |-- raw copy -> data/raw/<run_id>/*.jsonl
    v
src/transform.py
    |
    v
src/validate.py
    |                  |
    | valid records    | rejected records
    v                  v
src/load.py         rejected_records table
    |
    v
PostgreSQL orders table
```

## Folder Structure

```text
02-python-practice/
  docker-compose.yml
  Dockerfile
  README.md
  .env.example
  pyproject.toml
  src/
    config.py
    extract.py
    transform.py
    validate.py
    load.py
    main.py
    logging_config.py
  tests/
  data/
    sample/
    bad/
    raw/
    processed/
    rejected/
  sql/
    00_schema.sql
  exercises/
  broken/
  solutions/
  runbook/
```

## Prerequisites

Required:

- Python 3.11 or newer.
- Docker Desktop if running PostgreSQL locally.

Recommended:

- WSL2 Ubuntu on Windows.
- VS Code Remote WSL.

## Setup

From this folder:

```powershell
cd C:\Users\ADMIN\Documents\Codex\2026-05-09\https-github-com-datatalksclub-data-engineering\02-python-practice
```

Create env file:

```powershell
Copy-Item .env.example .env
```

Create Python virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
```

Start PostgreSQL:

```powershell
docker compose up -d postgres
```

Check database:

```powershell
docker compose exec postgres psql -U de_user -d python_practice -c "select current_database();"
```

## Run the Pipeline

### CSV ingestion

```powershell
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09
```

Expected:

- 6 records extracted.
- 2 rejected records:
  - missing `customer_id`
  - invalid amount
- duplicate `O2002` deduplicated by latest `updated_at`.
- records upserted into `orders`.

### JSON ingestion

```powershell
python -m src.main --source json --input-path data/sample/orders.json --run-date 2026-05-09
```

### JSONL ingestion

```powershell
python -m src.main --source jsonl --input-path data/sample/orders.jsonl --run-date 2026-05-09
```

### Simulated API ingestion

```powershell
python -m src.main --source api --api-pages-dir data/sample/api_pages --run-date 2026-05-09
```

Expected:

- 3 pages fetched.
- Page 2 simulates timeout once.
- Page 3 simulates rate limit once.
- retry logs appear.
- duplicate `O5004` deduplicated by latest `updated_at`.

## Verify Results

Query loaded orders:

```powershell
docker compose exec postgres psql -U de_user -d python_practice -c "select order_id, customer_id, status, amount, run_id from orders order by order_id;"
```

Query audit table:

```powershell
docker compose exec postgres psql -U de_user -d python_practice -c "select run_id, source_name, status, extracted_count, valid_count, rejected_count, loaded_count from pipeline_runs order by started_at desc;"
```

Query rejected records:

```powershell
docker compose exec postgres psql -U de_user -d python_practice -c "select source_name, reason, raw_record from rejected_records order by rejected_record_id;"
```

## Idempotency Check

Run the same CSV ingestion twice with the same `run_id`:

```powershell
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09 --run-id csv_idempotency_test
python -m src.main --source csv --input-path data/sample/orders.csv --run-date 2026-05-09 --run-id csv_idempotency_test
```

Check duplicates:

```powershell
docker compose exec postgres psql -U de_user -d python_practice -c "select order_id, count(*) from orders group by order_id having count(*) > 1;"
```

Expected:

- zero rows.

Why:

- `orders.order_id` is the primary key.
- `src/load.py` uses PostgreSQL upsert.
- latest `updated_at` wins.

## Run Tests

```powershell
pytest
```

Tests cover:

- status normalization.
- amount parsing.
- order normalization.
- deduplication.
- required column validation.
- malformed JSONL handling.

## Exercises

Recommended order:

1. [Level 01 - CSV](./exercises/level_01_csv.md)
2. [Level 02 - JSON and JSONL](./exercises/level_02_json_jsonl.md)
3. [Level 03 - Simulated API](./exercises/level_03_simulated_api.md)
4. [Level 04 - PostgreSQL Load](./exercises/level_04_postgres_load.md)
5. [Level 05 - Tests](./exercises/level_05_tests.md)
6. [Level 06 - Debug Broken Ingestion](./exercises/level_06_debug_broken.md)

## Broken Scenarios

Intentional failures:

- `broken/01_pagination_bug.py`: pagination misses records.
- `broken/02_retry_duplicate_load.py`: retry creates duplicates.
- `broken/03_partial_file_write.py`: final file partially written.
- `broken/04_missing_env_var.md`: missing env var.
- `broken/05_invalid_required_columns.md`: required columns missing.

Matching solutions:

- `solutions/01_pagination_solution.md`
- `solutions/02_retry_duplicate_solution.md`
- `solutions/03_partial_file_write_solution.md`
- `solutions/04_validation_solution.md`

## Debugging Workflow

When data is missing:

1. Check structured logs.
2. Check `pipeline_runs.extracted_count`.
3. Check raw copy under `data/raw/<run_id>/`.
4. Check rejected records.
5. Check pagination logs.

When duplicates appear:

1. Check business key.
2. Check target primary key.
3. Check upsert logic.
4. Check retry behavior.
5. Check source duplicate records.

When the pipeline fails:

1. Read the first exception.
2. Check whether failure happened in extract, transform, validate, or load.
3. Check `.env`.
4. Check database availability.
5. Open [runbook/python_ingestion_runbook.md](./runbook/python_ingestion_runbook.md).

## Docker Pipeline Run

You can also run the pipeline container:

```powershell
docker compose --profile pipeline up --build pipeline
```

This runs simulated API ingestion against PostgreSQL inside the Compose network.

## Production Lessons

- Retry without idempotency creates duplicates.
- Raw data is insurance for reprocessing.
- Pagination must be logged and tested.
- Validation should fail fast for source contract breaks.
- Bad records should be visible, not silently dropped.
- Structured logs should include counts and run IDs.
- CLI arguments make local runs and orchestrated runs consistent.

