# Level 03 - Partitioning and Clustering

## Goal

Build partitioned and clustered marts based on query pattern.

## Tasks

1. Run `bigquery/ddl/03_staging_views.sql`.
2. Run `bigquery/ddl/04_marts_partitioned_clustered.sql`.
3. Query `fct_orders` with `order_date` filter.
4. Query `fct_orders` without `order_date` filter.
5. Compare dry-run bytes processed.
6. Query with `customer_id = 'C001'` and discuss clustering.

## Expected Output

`mart_daily_revenue` should return daily rows for May 1-3.

Business expectation:

- Cancelled and refunded orders should have `recognized_revenue = 0`.
- Paid/shipped/completed orders should count captured payments as recognized revenue.

## Questions

- Why partition by `order_date`?
- When would ingestion date be a better partition key?
- Why cluster by `customer_id` and `order_status`?

