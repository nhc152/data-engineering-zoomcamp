# Level 02 - Reconciliation

## Goal

Compare source and mart metrics to detect silent business errors.

## Tasks

1. Run `sql/checks/06_reconciliation_checks.sql`.
2. Identify mismatched dates.
3. Explain whether mismatch is expected or a bug.
4. Propose threshold.
5. Propose alert severity.

## Expected Learning

Reconciliation is one of the strongest checks for finance and revenue pipelines.

## Questions

- Should refunded orders reduce revenue?
- Should cancelled orders have recognized revenue?
- Should reconciliation compare raw payments to order revenue directly?

