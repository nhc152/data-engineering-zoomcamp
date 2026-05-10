# Broken Scenario 03 - New Status Value Breaks Metric

## Symptom

Source introduces a new order status:

```text
partially_refunded
```

Existing logic treats it as unknown or excludes it incorrectly.

## Diagnostic SQL

Run:

```text
sql/checks/04_validity_checks.sql
```

## Prevention

- Accepted values check.
- Data contract with producer.
- Alert on new enum values.
- Review business metric impact before mapping.

