# Model Answer - Ecommerce Warehouse

## Pattern Choice

Batch ELT.

Daily finance and product reporting do not require streaming. Batch ELT gives better auditability, lower operational complexity, easier backfill, and straightforward quality checks.

## Architecture

```text
orders/payments/customers/products sources
  -> raw landing on object storage
  -> warehouse raw tables
  -> staging models
  -> facts and dimensions
  -> marts: daily revenue, customer LTV, product performance
  -> BI dashboards
```

## Volume Estimate

Assume:

- 1M orders/day.
- 3M order item rows/day.
- 1.2M payment/refund events/day.
- 3 years retention.

This is well within warehouse batch processing if tables are partitioned and marts are pre-aggregated.

## Storage and Modeling

- Raw layer: immutable files/tables with ingestion timestamp.
- Staging: cast, clean, dedup.
- Facts: `fct_orders`, `fct_order_items`, `fct_payments`.
- Dimensions: `dim_customers`, `dim_products`.
- Marts: `mart_daily_revenue`, `mart_customer_ltv`.

## Bottlenecks

- API/source extraction rate.
- Late refunds updating historical revenue.
- Warehouse scan cost.
- Join explosion between orders and order items.

## Reliability

- Partition-level backfill.
- Idempotent loads.
- dbt/data quality tests.
- Reconciliation between payments and order totals.
- Run metadata and freshness checks.

## Data Quality

- Unique order_id/payment_id.
- Not null keys.
- Accepted status values.
- Referential integrity.
- Daily payment reconciliation.
- Freshness by 8 AM.

## Cost

- Partition facts by date.
- Cluster by customer/product if query pattern supports it.
- Use aggregate marts for dashboards.
- Avoid scanning raw tables from BI.

## Trade-offs

This design favors correctness and replayability over low latency. If intraday finance reporting becomes required, I would add CDC or hourly micro-batch for core tables.

