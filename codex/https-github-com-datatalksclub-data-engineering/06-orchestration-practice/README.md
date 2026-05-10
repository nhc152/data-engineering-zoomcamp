# Orchestration Practice Lab

## Goal

Practice production orchestration concepts with a small ecommerce pipeline:

```text
extract_orders
  -> load_raw_orders
  -> validate_raw_orders
  -> build_marts
  -> validate_marts
  -> notify_success
```

This lab uses Kestra as the main orchestration tool because YAML flows are easy to inspect while learning. The task scripts are plain Python, so you can also run them manually without Kestra to understand what each task does.

## What This Lab Teaches

- DAG/flow design.
- Task boundaries.
- Logical date vs current date.
- Scheduling.
- Retry policy.
- Idempotency.
- Backfill.
- Dependency failure.
- Data quality failure.
- Retry storm.
- Stale mart even when flow succeeds.
- Alert/runbook mindset.

## Folder Structure

```text
06-orchestration-practice/
  docker-compose.yml
  README.md
  flows/
  scripts/
  data/
    source/
    raw/
    marts/
    state/
  exercises/
  broken/
  solutions/
  runbook/
```

## Prerequisites

Required:

- Python 3.11+.
- Docker Desktop if you want to run Kestra UI.

No real cloud credentials are needed.

## Quick Start Without Kestra

Run a single pipeline day manually:

```bash
python scripts/extract_orders.py --run-date 2026-05-01
python scripts/load_raw_orders.py --run-date 2026-05-01
python scripts/validate_raw_orders.py --run-date 2026-05-01
python scripts/build_marts.py --run-date 2026-05-01
python scripts/validate_marts.py --run-date 2026-05-01
python scripts/notify_success.py --run-date 2026-05-01
```

Backfill three days:

```bash
python scripts/run_backfill.py --start-date 2026-05-01 --end-date 2026-05-03
```

Reset generated outputs:

```bash
python scripts/reset_lab.py
```

## Run Kestra

Start Kestra:

```bash
docker compose up -d
```

Open:

```text
http://localhost:8080
```

Import the flow:

```text
flows/ecommerce_daily_orders.yml
```

Run with input:

```text
run_date = 2026-05-01
```

Backfill manually by running:

```text
2026-05-01
2026-05-02
2026-05-03
```

## Pipeline Data Model

Source files:

```text
data/source/orders_2026-05-01.csv
data/source/orders_2026-05-02.csv
data/source/orders_2026-05-03.csv
```

Raw outputs:

```text
data/raw/orders/run_date=YYYY-MM-DD/orders.csv
```

Mart outputs:

```text
data/marts/daily_revenue.csv
```

Run metadata:

```text
data/state/run_log.jsonl
```

## Task Boundaries

| Task | Responsibility | Retry? | Why |
|---|---|---|---|
| `extract_orders` | Copy source file to landing path | Yes | Simulates transient source/API issue |
| `load_raw_orders` | Write raw partition idempotently | Yes | Safe because it overwrites same partition |
| `validate_raw_orders` | Check row count and required columns | No | Data quality failure needs investigation |
| `build_marts` | Rebuild daily revenue mart from raw partitions | Yes | Safe if deterministic |
| `validate_marts` | Check freshness and metric sanity | No | Wrong metric should block publish |
| `notify_success` | Write success message | No | Side effect should not be retried blindly |

## Logical Date Rule

Every task takes `--run-date`. The business date comes from the orchestrator input, not from `current_date`.

Correct:

```bash
python scripts/extract_orders.py --run-date 2026-05-01
```

Wrong:

```python
run_date = date.today()
```

Backfill only works if every task uses the logical date.

## Failure Scenarios

This lab includes broken scenarios:

- `broken/retry_storm_flow.yml`
- `broken/non_idempotent_backfill.py`
- `broken/current_date_bug.py`
- `broken/stale_mart_success.py`
- `broken/sensor_waits_forever.yml`
- `broken/downstream_dependency_missing.yml`

Solutions:

- `solutions/fixed_idempotent_load.py`
- `solutions/fixed_logical_date.py`
- `solutions/fixed_dependency_flow.yml`
- `solutions/retry_policy_notes.md`

## Exercise Order

1. `exercises/level_01_manual_pipeline.md`
2. `exercises/level_02_kestra_flow.md`
3. `exercises/level_03_retry_and_failure.md`
4. `exercises/level_04_backfill_idempotency.md`
5. `exercises/level_05_data_quality_failure.md`
6. `exercises/level_06_debugging_incidents.md`

## Debugging Workflow

When a run fails:

1. Identify failed task.
2. Identify `run_date`.
3. Read task log.
4. Check input file exists.
5. Check output partition exists.
6. Check run metadata.
7. Decide if retry is safe.
8. If data quality failed, do not blindly retry.
9. Write incident note if business output was wrong.

See:

```text
runbook/failed_flow_runbook.md
```

## Interview Skills

After this lab, you should be able to explain:

- DAG vs task.
- Logical date vs current date.
- Retry vs backfill.
- Idempotency.
- Why data quality failures should not always retry.
- How backfill can duplicate data.
- How a DAG can succeed while data is stale.
- How to triage failed orchestration runs.

