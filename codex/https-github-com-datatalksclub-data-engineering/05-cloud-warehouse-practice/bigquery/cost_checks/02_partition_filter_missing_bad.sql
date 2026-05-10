-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Bad query: no partition filter. On large tables this scans every partition.
-- Run as dry run and compare bytes processed with 01_partition_filter_good.sql.

select
  order_status,
  sum(recognized_revenue) as recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
group by order_status;

