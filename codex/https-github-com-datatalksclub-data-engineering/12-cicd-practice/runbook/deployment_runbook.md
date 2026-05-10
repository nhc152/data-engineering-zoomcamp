# Deployment Runbook

## Pre-Deployment Checklist

- Python tests pass.
- dbt build passes in CI.
- dbt tests pass.
- No secrets in diff.
- No hard-coded prod target.
- Metric changes reviewed by owner.
- Backfill requirement documented.
- Rollback plan documented.

## Deployment Steps

1. Merge approved PR.
2. Build artifacts or dbt project.
3. Deploy to staging target.
4. Run smoke tests.
5. Compare row counts and metrics.
6. Approve production deployment.
7. Monitor first production run.

## Rollback Steps

1. Identify whether issue is code, config, or data.
2. Revert code if needed.
3. Stop bad pipeline runs.
4. Identify impacted tables/date ranges.
5. Restore snapshot or reprocess from raw.
6. Validate fixed data.
7. Publish fixed data.
8. Write incident report.

## Data vs Code Rollback

Code rollback:

- changes future behavior
- does not repair already-written data

Data rollback:

- restores or rebuilds affected state
- may require snapshots, raw reprocessing, or backfill

