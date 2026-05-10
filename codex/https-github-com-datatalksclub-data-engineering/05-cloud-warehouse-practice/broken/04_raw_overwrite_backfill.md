# Broken Scenario 04 - Raw File Overwritten During Backfill

## Symptom

Yesterday's raw file changed after a backfill. Reprocessing no longer reproduces the original result.

## Bad Layout

```text
raw/ecommerce/orders/orders.csv
```

Every run writes the same object path.

## Better Layout

```text
raw/ecommerce/orders/ingestion_date=2026-05-01/orders_run_001.csv
raw/ecommerce/orders/ingestion_date=2026-05-01/orders_backfill_2026-05-09.csv
```

## Prevention

- Include ingestion date.
- Include run ID or file timestamp when backfilling.
- Keep raw append-only.
- Rebuild downstream managed tables from raw.

