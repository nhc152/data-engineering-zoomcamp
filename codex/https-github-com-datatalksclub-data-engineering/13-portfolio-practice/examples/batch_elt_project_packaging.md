# Example Packaging - Batch ELT Project

## Project Summary

Build a daily ecommerce analytics pipeline:

```text
CSV/API -> Python ingestion -> GCS/local raw -> BigQuery/Postgres -> dbt marts -> quality checks -> orchestration
```

## Strong README Angle

This project demonstrates:

- raw data preservation
- warehouse modeling
- dbt tests
- idempotent daily load
- backfill strategy
- revenue reconciliation

## Architecture Notes

Mention:

- raw files are stored before transformation
- dbt builds staging/intermediate/marts
- facts and dimensions have documented grain
- data quality checks block bad publish

## Good Trade-Offs to Explain

- Batch is enough because dashboard latency is daily.
- ELT keeps transformations in SQL and dbt lineage.
- Incremental load reduces runtime but requires watermark/lookback.
- BigQuery/Postgres chosen for SQL analytics and reproducibility.

## Failure Story

Use this in interview:

```text
One realistic failure is duplicate orders after rerunning ingestion. I prevent this by deduplicating in staging using the business key and using merge/upsert when loading facts. I also add a unique test on `fct_orders.order_id`.
```

