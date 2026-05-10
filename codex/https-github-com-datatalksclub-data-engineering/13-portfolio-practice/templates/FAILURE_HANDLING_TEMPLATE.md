# Failure Handling Template

Use this section in your project README.

## Failure Matrix

| Failure | Detection | Impact | Recovery | Prevention |
|---|---|---|---|---|
| API timeout | task logs/retry count | data delay | retry with backoff | timeout + retry policy |
| Source schema drift | load or staging failure | pipeline blocked or bad data | update schema through PR | schema validation |
| Duplicate source rows | unique test failure | inflated metrics | dedup staging/rebuild mart | unique key tests |
| Late-arriving data | reconciliation/freshness gap | missing historical updates | rerun lookback window | updated_at watermark |
| Join explosion | row count increase | duplicate revenue | aggregate child grain first | grain checks |
| Cost spike | billing/job history | high cloud cost | stop query, rewrite, create mart | partition filter + review |

## Idempotency

Explain:

- What happens if the job runs twice?
- Which keys prevent duplicates?
- Is the target append, merge, or partition overwrite?

Example:

```text
The order fact uses merge on `order_id`. Rerunning the same date updates existing rows instead of appending duplicates.
```

## Backfill

Explain:

- How to rerun one day.
- How to rerun a date range.
- Whether downstream dashboards are paused.
- Which checks must pass before publish.

## Publish Gate

Data is considered publishable only when:

- raw freshness passes
- primary keys are unique
- required fields are not null
- accepted values are valid
- reconciliation is within tolerance

