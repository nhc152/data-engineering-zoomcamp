# Level 05 - Data Quality Failure

## Goal

Practice blocking downstream marts when raw data is invalid.

## Tasks

1. Make the bad source active:

```bash
copy data\source\orders_2026-05-04_bad.csv data\source\orders_2026-05-04.csv
```

2. Run:

```bash
python scripts/extract_orders.py --run-date 2026-05-04
python scripts/load_raw_orders.py --run-date 2026-05-04
python scripts/validate_raw_orders.py --run-date 2026-05-04
```

## Expected Output

Validation fails because:

- one row has missing `customer_id`
- one row has invalid `order_status`

## Questions

- Why should this not retry automatically?
- What alert should be sent?
- Should raw data be kept?
- Should mart publish be blocked?

