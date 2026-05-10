# Runbook - New Status Value

## Symptoms

Accepted values check fails because a new enum/status appears.

## Triage

1. Identify new status.
2. Count affected rows.
3. Ask source owner whether status is expected.
4. Determine metric impact.
5. Update mapping deliberately.

## SQL

Run:

```text
sql/checks/04_validity_checks.sql
```

## Mitigation

- Quarantine unknown status if impact is unclear.
- Patch mapping only after business review.
- Backfill affected marts.

## Prevention

- Data contract.
- Producer notification for enum changes.
- Accepted values alert.

