-- Broken scenario: query scans all partitions because it has no partition filter.
-- Replace PROJECT_ID and MARTS_DATASET.

select
  customer_id,
  sum(recognized_revenue) as recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
group by customer_id
order by recognized_revenue desc;

