-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Uses clustered column customer_id on fct_orders.

select
  customer_id,
  count(*) as order_count,
  sum(recognized_revenue) as recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
where order_date between date '2026-05-01' and date '2026-05-31'
  and customer_id = 'C001'
group by customer_id;

