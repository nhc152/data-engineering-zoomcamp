# Runbook Template

## Pipeline

Name:

Owner:

Schedule:

SLA:

Critical outputs:

## Normal Run

Commands:

```bash
<command>
```

Expected outputs:

- row count:
- latest partition:
- quality checks:

## Incident: Pipeline Failed During Load

### Symptoms

- load task failed
- raw file exists but warehouse table not updated

### Triage

1. Check orchestrator logs.
2. Check raw file path.
3. Check schema/header.
4. Check warehouse load job error.
5. Check service account permissions.
6. Check whether rerun is idempotent.

### Mitigation

- Fix source/schema issue.
- Rerun affected partition.
- Run quality checks.
- Publish only after validation.

## Incident: Duplicate Records Inflated Metric

### Triage

1. Check raw duplicate keys.
2. Check staging dedup logic.
3. Check fact unique key.
4. Check incremental append vs merge.
5. Check row count before/after joins.

### Prevention

- unique tests
- merge/upsert by business key
- reconciliation checks

## Incident: Late-Arriving Data Missed

### Triage

1. Check watermark.
2. Check `updated_at` vs `created_at`.
3. Check lookback window.
4. Check affected dates.

### Mitigation

- rerun affected lookback window
- widen lookback if needed
- use merge/upsert

## Incident: Dashboard Query Too Expensive

### Triage

1. Check query history.
2. Check bytes scanned.
3. Check partition filter.
4. Check `select *`.
5. Check whether dashboard queries raw/fact instead of mart.

### Mitigation

- add partition filter
- create aggregate mart
- adjust refresh cadence

## Post-Incident Notes

- Impact:
- Root cause:
- Fix:
- Prevention:
- Owner:
- Follow-up date:

