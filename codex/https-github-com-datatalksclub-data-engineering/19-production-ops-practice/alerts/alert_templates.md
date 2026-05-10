# Alert Templates

## Good Alert Requirements

Every alert must include:

- pipeline name
- environment
- severity
- data interval
- symptom
- business impact
- owner
- runbook link
- dashboard/log link
- first diagnostic command/query

## Template: Pipeline Failed

```text
[SEV2] ecommerce_daily_revenue failed for 2026-05-08

Pipeline: ecommerce_daily_revenue
Environment: prod
Failed task: load_orders_raw
Data interval: 2026-05-08 00:00 -> 2026-05-09 00:00 Asia/Saigon
Impact: mart_daily_revenue may miss previous-day revenue before 07:00 SLA
Owner: Data Engineering
Runbook: runbooks/failed_daily_pipeline.md
Logs: <orchestrator_run_url>
First check: verify raw source freshness and task error message
```

## Template: Data Quality Blocked Publish

```text
[SEV1] mart_daily_revenue publish blocked by revenue reconciliation

Table: mart_daily_revenue
Partition: 2026-05-08
Check: revenue_reconciliation_delta
Measured: 4.8%
Threshold: 0.1%
Impact: finance dashboard remains on previous published partition
Owner: Data Engineering + Finance Analytics
Runbook: runbooks/data_quality_publish_block.md
Sample rows query: <query link>
```

## Template: Freshness Breach

```text
[SEV2] orders source stale

Source: orders API
Latest source timestamp: 2026-05-08 13:12 Asia/Saigon
Expected: data within 24 hours
Impact: daily revenue may be incomplete
Owner: Source team + Data Engineering
Runbook: runbooks/stale_data_after_success.md
```

## Bad Alert Example

```text
Task failed.
```

This is not actionable. It has no owner, impact, data interval, or runbook.

