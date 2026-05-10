# Publish Gate Design

## Purpose

A publish gate prevents bad data from becoming official data.

It separates:

```text
build table
  -> validate table
  -> publish table/partition
```

## Why It Matters

Without a publish gate:

- DAG can succeed but data can be stale.
- Dashboard can read partially built tables.
- Data quality failure can reach business users.
- Backfill can corrupt current partitions.

## Gate Inputs

The gate checks:

- pipeline run status
- freshness
- duplicate keys
- row count anomaly
- reconciliation
- schema validation
- cost estimate
- owner override if needed

## Gate Decision

| Check | Severity | Action |
|---|---|---|
| Duplicate primary key | Block | Do not publish |
| Missing partition | Block | Do not publish |
| Revenue mismatch >= 0.1% | Block | Do not publish |
| Freshness > 24h | Block | Do not publish |
| Cost 20% above normal | Warn | Publish with note |
| Optional dimension field null spike | Warn | Publish with note |

## Publish Pattern

Safe pattern:

```text
build temp table/partition
  -> run checks
  -> swap or insert into published table
  -> record publish event
```

Unsafe pattern:

```text
write directly into published table
```

## Manual Override

Manual override must include:

- approver
- reason
- expiry
- impacted tables
- downstream consumers notified

## Required Metadata

Record every gate decision in `ops.publish_events`.

