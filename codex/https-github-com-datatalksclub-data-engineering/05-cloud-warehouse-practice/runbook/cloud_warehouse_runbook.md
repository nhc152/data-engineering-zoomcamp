# Cloud Warehouse Runbook

## Incident: BigQuery Query Cost Spike

### Symptoms

- Billing alert fires.
- BigQuery job history shows higher bytes processed.
- Dashboard refresh becomes expensive.

### Triage

1. Open BigQuery job history.
2. Identify top jobs by bytes processed.
3. Identify user/service account.
4. Check query text.
5. Check for missing partition filter.
6. Check for `select *`.
7. Check whether query uses raw/fact table instead of mart.

### Mitigation

- Pause dashboard refresh if needed.
- Add partition filter.
- Replace raw query with mart query.
- Create aggregate table if query repeats frequently.
- Add code review rule for partitioned facts.

## Incident: Load Job Failed

### Triage

1. Check GCS file path.
2. Check dataset and bucket location.
3. Check schema/header.
4. Check load job error details.
5. Check service account permissions.
6. Check whether source changed schema.

### Mitigation

- Keep raw files.
- Fix schema or staging model.
- Rerun load.
- Backfill downstream tables if needed.

## Incident: Missing Data in Mart

### Triage

1. Does raw file exist in GCS?
2. Does external table read rows?
3. Does managed raw table have rows?
4. Does staging view filter/cast rows out?
5. Does mart partition exist?
6. Was the scheduled run successful?

### Prevention

- Freshness checks.
- Row count checks.
- Reconciliation checks.
- Run metadata table.
- Alert with owner and runbook link.

