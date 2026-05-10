# Level 03 - Retry and Failure

## Goal

Understand retries and why not every failure should retry.

## Transient Failure

Run:

```bash
python scripts/reset_lab.py
set SIMULATE_EXTRACT_TRANSIENT_FAILURE=1
python scripts/extract_orders.py --run-date 2026-05-01
python scripts/extract_orders.py --run-date 2026-05-01
```

On Unix-like shells:

```bash
SIMULATE_EXTRACT_TRANSIENT_FAILURE=1 python scripts/extract_orders.py --run-date 2026-05-01
SIMULATE_EXTRACT_TRANSIENT_FAILURE=1 python scripts/extract_orders.py --run-date 2026-05-01
```

## Data Quality Failure

Copy bad file and run validation:

```bash
python scripts/reset_lab.py
copy data\source\orders_2026-05-04_bad.csv data\source\orders_2026-05-04.csv
python scripts/extract_orders.py --run-date 2026-05-04
python scripts/load_raw_orders.py --run-date 2026-05-04
python scripts/validate_raw_orders.py --run-date 2026-05-04
```

## Expected Learning

- Extract can retry if failure is transient.
- Data quality failure should fail fast and alert.
- Retrying bad data does not fix bad data.

