# Level 04 - Cost Debugging

## Goal

Practice identifying expensive queries before they become a billing surprise.

## Tasks

1. Dry run `bigquery/cost_checks/01_partition_filter_good.sql`.
2. Dry run `bigquery/cost_checks/02_partition_filter_missing_bad.sql`.
3. Dry run `bigquery/cost_checks/03_select_star_bad.sql`.
4. Dry run `bigquery/cost_checks/04_column_pruning_good.sql`.
5. Record bytes processed for each.
6. Explain which query is safer for dashboards.

## Expected Output

For this small lab, bytes may be tiny. The important skill is reading dry-run output and understanding the pattern.

On large tables:

- Missing partition filter scans more data.
- `select *` scans more columns.
- Aggregate marts reduce repeated dashboard cost.

## Questions

- What query pattern would you block in code review?
- How would you prevent dashboard full scans?
- When is creating a mart worth the storage cost?

