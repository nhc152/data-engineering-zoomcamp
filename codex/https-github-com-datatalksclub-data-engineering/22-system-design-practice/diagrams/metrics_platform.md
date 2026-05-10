# Diagram - Metrics Platform

```mermaid
flowchart LR
  A["Facts and Dimensions"] --> B["Metric Definitions"]
  B --> C["Semantic Layer / Metrics Store"]
  C --> D["BI Dashboards"]
  C --> E["Experimentation"]
  C --> F["Reverse ETL / Apps"]
  B --> G["Metric Tests"]
  A --> H["Lineage and Catalog"]
```

## Bottlenecks

- Conflicting metric definitions.
- Query performance for common metrics.
- Ownership and approval workflow.
- Backfill when metric logic changes.

## Reliability

- Metric contracts.
- Versioned definitions.
- Reconciliation checks.
- Downstream impact analysis.

