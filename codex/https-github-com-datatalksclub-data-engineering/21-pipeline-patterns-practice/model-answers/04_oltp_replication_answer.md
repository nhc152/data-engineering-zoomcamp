# Model Answer - OLTP Replication

## Recommended Pattern

CDC to warehouse.

## Why

The source is mutable OLTP tables and analytics needs current-state data with deletes. CDC captures inserts, updates, and deletes without repeatedly querying production OLTP tables.

## Architecture

```text
OLTP database
  -> CDC connector
  -> raw changelog
  -> current-state tables
  -> warehouse marts
```

## Required Controls

- Operation type: insert/update/delete.
- Source log position.
- Event timestamp and ingestion timestamp.
- Schema evolution policy.
- Resnapshot plan.

## Failure Modes

- WAL/binlog expires.
- Deletes ignored.
- Out-of-order updates.
- Schema rename.

## Trade-off Language

CDC is more complex than API polling, but it is better for mutable database replication because it captures every change and avoids heavy reads on the OLTP source.

