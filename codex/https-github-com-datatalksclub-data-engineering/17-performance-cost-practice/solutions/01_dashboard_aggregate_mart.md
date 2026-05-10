# Solution 01 - Dashboard Uses Aggregate Mart

## Fix

Replace dashboard raw events query with aggregate mart query.

Use:

- `sql/09_create_aggregate_mart.sql`
- `sql/08_aggregate_mart_good.sql`

## Why It Works

The dashboard no longer scans raw events every refresh. It scans a smaller table already aggregated by date and event name.

## Trade-off

- Adds storage for mart.
- Adds refresh job.
- Dashboard data is only as fresh as mart refresh.

## Prevention

- Code review rule: dashboards should not query raw event tables directly.
- Cost alert by BI service account.
- Mart freshness check.

