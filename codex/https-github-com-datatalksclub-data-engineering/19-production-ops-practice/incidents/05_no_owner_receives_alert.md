# Incident 05 - No Owner Receives Alert

## Timeline

```text
06:40 Data quality check failed
06:41 Alert sent to deprecated Slack channel
07:30 Business user noticed dashboard stale
08:00 Data Engineering found alert routing issue
08:20 Correct owner notified
09:00 Pipeline fixed
```

## Impact

SLA breach was detected by business users instead of monitoring.

## Root Cause

Alert routing metadata was stale. Table owner was not maintained.

## Detection Gap

No periodic ownership review.

## Immediate Fix

Updated alert route and reran pipeline.

## Prevention

- Owner required for production tables.
- Quarterly ownership review.
- Alerts must include owner and runbook.
- Test alert routing.

