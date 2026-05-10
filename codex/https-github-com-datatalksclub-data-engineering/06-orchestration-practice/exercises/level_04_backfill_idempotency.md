# Level 04 - Backfill and Idempotency

## Goal

Backfill multiple days without duplicating data.

## Good Backfill

Run:

```bash
python scripts/reset_lab.py
python scripts/run_backfill.py --start-date 2026-05-01 --end-date 2026-05-03
```

Run it again:

```bash
python scripts/run_backfill.py --start-date 2026-05-01 --end-date 2026-05-03
```

## Expected Output

Raw partitions are replaced idempotently:

```text
data/raw/orders/run_date=2026-05-01/orders.csv
data/raw/orders/run_date=2026-05-02/orders.csv
data/raw/orders/run_date=2026-05-03/orders.csv
```

`daily_revenue.csv` should not double revenue after rerun.

## Broken Backfill

Run:

```bash
python broken/non_idempotent_backfill.py
```

## Questions

- Why does append create duplicates?
- Why is replace-partition safer for this lab?
- When would merge/upsert be better than replace-partition?

