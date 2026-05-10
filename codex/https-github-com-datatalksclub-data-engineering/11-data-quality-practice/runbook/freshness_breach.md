# Runbook - Freshness Breach

## Symptoms

Freshness check fails. Latest data timestamp or business date is older than SLA.

## Triage

1. Check upstream source delivery.
2. Check raw layer row count for expected date.
3. Check ingestion job status.
4. Check staging filters.
5. Check mart refresh time.
6. Check whether backfill or deployment happened.

## SQL

Run:

```text
sql/checks/01_freshness_checks.sql
sql/checks/02_completeness_volume_checks.sql
```

## Mitigation

- If source missing, notify source owner.
- If ingestion failed, rerun ingestion.
- If transform failed, rerun transform for affected date.
- If mart stale, rebuild affected partition.

## Prevention

- Source delivery SLA.
- Freshness alert with owner.
- Run metadata.
- Publish gate before dashboard refresh.

