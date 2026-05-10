# GCS Layout

## Recommended Bucket Pattern

```text
gs://<company-or-user>-<env>-data-lake/
```

For this lab:

```text
gs://$GCS_BUCKET/
```

## Raw Zone

Raw files should preserve source shape and be append-only.

```text
raw/ecommerce/customers/ingestion_date=2026-05-01/customers.csv
raw/ecommerce/orders/ingestion_date=2026-05-01/orders.csv
raw/ecommerce/order_items/ingestion_date=2026-05-01/order_items.csv
raw/ecommerce/payments/ingestion_date=2026-05-01/payments.csv
```

## Why Use `ingestion_date`

`ingestion_date` answers:

- When did this file arrive?
- Which raw partition should be reprocessed?
- Did a backfill overwrite current data?

It is different from business date such as `order_date`.

## Backfill Rule

Never overwrite raw files silently.

Bad:

```text
raw/ecommerce/orders/orders.csv
```

Better:

```text
raw/ecommerce/orders/ingestion_date=2026-05-01/orders_run_001.csv
raw/ecommerce/orders/ingestion_date=2026-05-01/orders_backfill_2026-05-09.csv
```

## Layering

```text
raw/      source-like, append-only
staging/  optional cleaned files if using lake processing
curated/  optional analytics-ready files
```

For this lab, transformations happen in BigQuery, so only `raw/` is required in GCS.

