# Level 01 - Manual Pipeline

## Goal

Understand task boundaries before using an orchestrator.

## Tasks

Run:

```bash
python scripts/reset_lab.py
python scripts/extract_orders.py --run-date 2026-05-01
python scripts/load_raw_orders.py --run-date 2026-05-01
python scripts/validate_raw_orders.py --run-date 2026-05-01
python scripts/build_marts.py --run-date 2026-05-01
python scripts/validate_marts.py --run-date 2026-05-01
python scripts/notify_success.py --run-date 2026-05-01
```

## Expected Output

Generated files:

```text
data/raw/orders/run_date=2026-05-01/orders.csv
data/marts/daily_revenue.csv
data/state/run_log.jsonl
```

## Questions

- What is the input and output of each task?
- Which task should retry?
- Which task should fail fast?

