# Model Answer - Finance Reporting

## Recommended Pattern

Batch ELT.

## Why

Finance reporting needs accuracy, reconciliation, and replay more than sub-minute latency. Batch ELT keeps raw data, transforms in warehouse/dbt, and makes backfills straightforward.

## Architecture

```text
payment/order sources
  -> raw landing
  -> warehouse raw tables
  -> staging
  -> fct_orders/fct_payments
  -> mart_daily_revenue
  -> BI
```

## Quality Checks

- Row count by business date.
- Payment amount reconciliation.
- Duplicate order/payment IDs.
- Accepted payment status values.
- Freshness by 8 AM.

## Failure Modes

- Late-arriving payments missed.
- Incremental watermark uses wrong column.
- Refunds not applied.
- Backfill creates duplicates.

## Replay/Backfill

- Keep raw immutable.
- Rebuild affected partitions.
- Use merge/upsert or delete+insert partition.
- Compare before/after metrics.

## Trade-off Language

Batch ELT has higher latency than streaming, but it is simpler, easier to audit, cheaper to operate, and safer for finance-grade reporting.

