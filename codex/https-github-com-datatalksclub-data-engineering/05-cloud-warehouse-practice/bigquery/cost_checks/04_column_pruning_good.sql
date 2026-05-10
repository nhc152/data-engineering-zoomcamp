-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Better query: select only needed columns.

select
  order_id,
  customer_id,
  recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
where order_date = date '2026-05-01';

