# Runbook - Failed Daily Pipeline

## Purpose

Use this when `ecommerce_daily_revenue` fails before publishing.

## First 5 Minutes

1. Confirm environment is `prod`.
2. Identify failed task.
3. Identify data interval.
4. Check whether previous published data is still available.
5. Check if SLA is at risk.

## Triage Questions

1. Is this source, code, infra, credential, capacity, or data quality?
2. Did the task partially write data?
3. Can the task be rerun safely?
4. Is retry already happening?
5. Is upstream source available?
6. Who consumes the output?

## Diagnostic Steps

### Source issue

- Check source freshness.
- Check raw file/API availability.
- Check source incident channel.

### Warehouse issue

- Check quota/capacity.
- Check query job error.
- Check bytes processed and timeout.

### Credential issue

- Check service account permissions.
- Check secret rotation history.

### Data quality issue

- Open failing check.
- Inspect sample rows.
- Determine whether to block publish or override.

## Mitigation

- Rerun only idempotent tasks.
- If partial writes exist, clean temp output or rebuild affected partition.
- If SLA breach is likely, notify consumers.
- If publish is blocked, keep previous published data.

## Escalation

Escalate to SEV1 if:

- finance dashboard will show wrong numbers
- no previous partition is available
- data corruption reached published table

