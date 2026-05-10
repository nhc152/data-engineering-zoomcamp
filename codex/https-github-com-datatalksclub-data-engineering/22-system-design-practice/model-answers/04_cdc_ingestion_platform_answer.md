# Model Answer - CDC Ingestion Platform

## Pattern Choice

CDC to warehouse with raw changelog and current-state tables.

## Architecture

```text
OLTP databases
  -> CDC connectors
  -> raw changelog topics/tables
  -> current-state builder
  -> warehouse current tables
  -> dbt marts
```

## Volume Estimate

Assume:

- 20 source databases.
- 300 tables.
- 50k changes/sec peak.
- 5 minute freshness target.

The platform needs connector monitoring, lag tracking, and scalable sink merges.

## Bottlenecks

- Source log retention.
- Connector task throughput.
- Broker throughput.
- Warehouse merge cost.
- Schema evolution.

## Reliability

- Store raw changelog.
- Track source LSN/binlog position.
- Handle deletes explicitly.
- Maintain resnapshot plan.
- Reconcile source and target counts.

## Data Quality

- Primary key presence.
- Operation type validation.
- Current-state uniqueness.
- Delete propagation checks.
- Freshness by table.

## Cost

- Connector infrastructure.
- Broker/storage retention.
- Warehouse merge frequency.
- Raw changelog storage.

## Trade-offs

CDC reduces load on OLTP and improves freshness, but it is operationally complex. Deletes, schema drift, source log retention, and resnapshot strategy must be first-class design elements.

