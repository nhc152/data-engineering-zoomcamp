# Failed Flow Runbook

## First 5 Minutes

1. Identify failed flow and task.
2. Identify `run_date`.
3. Read the first failing task log.
4. Check whether upstream input exists.
5. Check whether task wrote partial output.
6. Decide whether retry is safe.

## Decision: Retry or Stop

Retry if:

- Network/API issue.
- Temporary service unavailable.
- Warehouse transient error.
- Task is idempotent.

Do not retry blindly if:

- Data quality check failed.
- Schema changed.
- Required column missing.
- Permission denied.
- Logic bug suspected.

## Backfill Safety Checklist

Before backfill:

- Confirm date range.
- Confirm output write mode.
- Confirm idempotency.
- Confirm downstream publish behavior.
- Estimate cost/runtime.
- Notify stakeholders if business dashboards are affected.

During backfill:

- Monitor row counts.
- Monitor failures per date.
- Avoid high concurrency if upstream is fragile.

After backfill:

- Reconcile row counts.
- Reconcile metrics.
- Check freshness.
- Record incident/backfill notes.

## DAG Success But Data Stale

Check:

1. Did validation actually check `run_date`?
2. Did mart include the run date?
3. Was source data available?
4. Did task use current date instead of logical date?
5. Did downstream query the latest partition?

## Alert Template

```text
Pipeline: ecommerce_daily_orders
Task: <task_id>
Run date: <YYYY-MM-DD>
Status: failed
Impact: <which table/dashboard/SLA>
Error: <short error>
Next action: <retry / investigate / block publish>
Runbook: runbook/failed_flow_runbook.md
Owner: data-platform
```

