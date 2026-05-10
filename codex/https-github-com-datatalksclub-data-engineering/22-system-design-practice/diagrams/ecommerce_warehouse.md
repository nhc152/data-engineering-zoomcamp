# Diagram - Ecommerce Warehouse

```mermaid
flowchart LR
  A["Orders API / DB Export"] --> B["Raw Landing: GCS/S3"]
  C["Payments API / DB Export"] --> B
  D["Customers Export"] --> B
  B --> E["Warehouse Raw Tables"]
  E --> F["Staging Models"]
  F --> G["Facts and Dimensions"]
  G --> H["Finance and Product Marts"]
  H --> I["BI Dashboards"]
  G --> J["Quality Checks"]
```

## Bottlenecks

- API rate limits.
- Late-arriving payments/refunds.
- Warehouse full scans.
- Incorrect joins causing duplicated revenue.

## Reliability

- Raw immutable files.
- Partition-level backfill.
- Reconciliation between payments and orders.
- Freshness checks before dashboard publish.

