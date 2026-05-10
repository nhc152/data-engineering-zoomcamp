# Incident Example - Pipeline Success but Dashboard Wrong

## Summary

The daily pipeline completed successfully, but the finance dashboard showed incorrect revenue due to duplicated order rows in the mart.

## Severity

P1 because a finance KPI was wrong.

## Impact

- Finance daily revenue dashboard affected.
- Business date: 2026-05-04.
- Revenue was overstated.

## Root Cause

The pipeline status monitored job success but did not validate data correctness. A retry appended duplicate rows.

## Detection

Manual report from Finance. No automated duplicate check existed.

## Fix

Rebuilt affected mart partition and added uniqueness check on `order_id`.

## Prevention

- Add unique check to publish gate.
- Add revenue reconciliation.
- Add alert with owner and runbook.

