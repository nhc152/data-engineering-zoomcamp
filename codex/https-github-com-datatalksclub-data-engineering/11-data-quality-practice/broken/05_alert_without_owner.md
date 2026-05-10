# Broken Scenario 05 - Alert Has No Owner

## Symptom

An alert says:

```text
Data quality failed.
```

No owner, no impact, no runbook.

## Why This Fails

Nobody knows:

- what failed
- who should respond
- whether it is urgent
- what downstream is affected
- how to fix it

## Fix

Use alert template:

```text
Severity:
Check:
Owner:
Table:
Business date:
Expected:
Actual:
Impact:
Runbook:
```

