# Diagram - CDC Ingestion Platform

```mermaid
flowchart LR
  A["OLTP Databases"] --> B["CDC Connectors"]
  B --> C["Raw Changelog Topics/Tables"]
  C --> D["Current State Builder"]
  D --> E["Warehouse Current Tables"]
  E --> F["dbt Marts"]
  C --> G["Replay / Resnapshot Path"]
  D --> H["DLQ / Error Table"]
```

## Bottlenecks

- Source log retention.
- Connector lag.
- Sink merge cost.
- Schema changes.

## Reliability

- Changelog retention.
- Delete handling.
- Source log position tracking.
- Resnapshot plan.
- Current-state reconciliation.

