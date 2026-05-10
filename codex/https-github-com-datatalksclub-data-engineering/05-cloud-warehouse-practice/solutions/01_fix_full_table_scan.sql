-- Fix for broken/02_full_table_scan.sql.
-- Replace PROJECT_ID and MARTS_DATASET.
-- Add partition filter. On large tables this reduces bytes scanned.

select
  customer_id,
  sum(recognized_revenue) as recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
where order_date between date '2026-05-01' and date '2026-05-31'
group by customer_id
order by recognized_revenue desc;

