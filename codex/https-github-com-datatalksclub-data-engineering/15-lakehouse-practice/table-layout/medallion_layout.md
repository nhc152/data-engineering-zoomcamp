# Sample Medallion Table Layout

## Object Storage Layout

```text
gs://company-prod-lakehouse/
  bronze/
    ecommerce/
      orders_cdc/
        table_metadata/
        data/
      payments_cdc/
        table_metadata/
        data/
      web_events/
        table_metadata/
        data/

  silver/
    ecommerce/
      orders_current/
        table_metadata/
        data/
      payments_clean/
        table_metadata/
        data/
      sessions/
        table_metadata/
        data/

  gold/
    finance/
      fct_orders/
        table_metadata/
        data/
      mart_daily_revenue/
        table_metadata/
        data/
    product/
      mart_funnel_conversion/
        table_metadata/
        data/
```

This is conceptual. Actual metadata directory names differ:

- Delta uses `_delta_log`.
- Iceberg uses metadata files and manifests.
- Hudi uses `.hoodie`.

## Bronze Table Contract

Example: `bronze.ecommerce.orders_cdc`

Grain:

```text
One row per source change event.
```

Required columns:

```text
event_id
source_table
operation
primary_key
payload
source_updated_at
ingestion_timestamp
batch_id
```

## Silver Table Contract

Example: `silver.ecommerce.orders_current`

Grain:

```text
One row per current order.
```

Rules:

- Deduplicate change events.
- Keep latest update by source order.
- Apply deletes.
- Normalize status.
- Validate required keys.

## Gold Table Contract

Example: `gold.finance.fct_orders`

Grain:

```text
One row per order.
```

Rules:

- Business metric definitions apply.
- Cancelled/refunded handling documented.
- Quality checks required.
- SLA required.

