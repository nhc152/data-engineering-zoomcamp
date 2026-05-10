# Conceptual Table Metadata Example

This is not exact Delta/Iceberg/Hudi syntax. It is a simplified mental model.

## Snapshot 001

```json
{
  "table": "silver.ecommerce.orders_current",
  "snapshot_id": "001",
  "schema_version": 1,
  "created_at": "2026-05-01T00:00:00Z",
  "operation": "initial_load",
  "active_files": [
    "data/part-0001.parquet",
    "data/part-0002.parquet"
  ],
  "removed_files": []
}
```

## Snapshot 002

```json
{
  "table": "silver.ecommerce.orders_current",
  "snapshot_id": "002",
  "schema_version": 1,
  "created_at": "2026-05-02T00:00:00Z",
  "operation": "merge_upsert",
  "active_files": [
    "data/part-0001.parquet",
    "data/part-0003.parquet"
  ],
  "removed_files": [
    "data/part-0002.parquet"
  ]
}
```

## Why Metadata Matters

Readers should not list all Parquet files and guess table state. They should read the active snapshot.

Metadata enables:

- consistent reads
- rollback
- time travel
- delete tracking
- schema evolution
- file pruning

