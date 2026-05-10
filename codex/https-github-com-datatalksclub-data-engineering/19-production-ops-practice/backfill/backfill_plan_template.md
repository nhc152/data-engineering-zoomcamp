# Backfill Plan Template

## Backfill Name

`<pipeline>_<date_range>_<reason>`

## Reason

Explain why backfill is needed:

- bug fix
- late-arriving data
- schema change
- metric definition change
- source replay

## Scope

Date range:

```text
start_date:
end_date:
```

Affected tables:

```text
raw:
staging:
facts:
marts:
dashboards:
```

## Safety Checks

Before running:

- Confirm backfill date range.
- Confirm affected tables.
- Estimate cost and runtime.
- Confirm idempotent write strategy.
- Decide whether downstream publish is paused.
- Notify consumers if data may change.
- Confirm rollback plan.

## Write Strategy

Choose one:

- delete + insert partition
- merge/upsert by primary key
- build temp table then swap
- full rebuild

Do not use blind append unless data is truly append-only and deduplicated.

## Validation

After running:

- row count by partition
- duplicate primary key check
- freshness check
- reconciliation check
- sample business metric comparison
- cost actual vs estimate

## Publish Plan

Publish only after validation passes.

Record:

- approver
- publish timestamp
- partitions published
- checks passed

