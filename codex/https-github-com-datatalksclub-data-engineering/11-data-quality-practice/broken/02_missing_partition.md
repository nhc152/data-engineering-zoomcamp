# Broken Scenario 02 - Source Stops Sending One Partition

## Symptom

The pipeline runs, but `order_date = 2026-05-04` has zero rows.

## Impact

Dashboard silently underreports revenue and active customers for that date.

## Diagnostic SQL

Run:

```text
sql/checks/02_completeness_volume_checks.sql
```

## Prevention

- Partition presence check.
- Expected file count.
- Source control totals.
- Alert owner with runbook.

