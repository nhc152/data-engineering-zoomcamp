# Data Pipeline Code Review Checklist

## General

- [ ] PR has a clear description.
- [ ] Change is scoped and reviewable.
- [ ] README/run commands are updated if needed.
- [ ] No secrets are committed.
- [ ] Generated data is not committed.

## SQL/dbt

- [ ] Grain is unchanged or explicitly documented.
- [ ] Primary/business key is clear.
- [ ] Join cardinality is safe.
- [ ] Incremental logic has a merge key or partition strategy.
- [ ] Late-arriving data is considered.
- [ ] Data tests are added or updated.

## Orchestration

- [ ] DAG/flow uses logical date, not uncontrolled `current_date`.
- [ ] Retry policy is safe.
- [ ] Task is idempotent.
- [ ] Backfill behavior is documented.

## Data Impact

- [ ] Row count impact is understood.
- [ ] Metric impact is understood.
- [ ] Backfill requirement is documented.
- [ ] Rollback plan exists.

## Operations

- [ ] Runbook is updated.
- [ ] Alerting impact is considered.
- [ ] Cost/performance impact is considered.

