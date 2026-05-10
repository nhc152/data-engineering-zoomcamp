# Level 03 - Anomaly Thresholds

## Goal

Use simple thresholds to detect suspicious metric changes.

## Tasks

1. Run `sql/checks/07_anomaly_threshold_checks.sql`.
2. Review trailing average and standard deviation.
3. Decide what should be P1, P2, or P3.
4. Explain why no-baseline days should not hard fail.

## Expected Learning

Thresholds need business context. A 50% drop can be normal on holidays, or critical on regular days.

## Deliverable

Write a threshold policy:

```text
metric: daily recognized revenue
baseline: trailing 7 days
failure: >3 stddev or >50% drop
owner: analytics-finance
runbook: runbook/freshness_breach.md
```

