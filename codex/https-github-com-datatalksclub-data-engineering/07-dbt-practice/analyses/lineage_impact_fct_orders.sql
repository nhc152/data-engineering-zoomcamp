-- Use this as an analysis file to discuss lineage impact.
-- `fct_orders` depends on:
-- - stg_ecommerce__orders
-- - int_order_items__aggregated_to_order
-- - int_payments__aggregated_to_order
--
-- In dbt docs, inspect all downstream models with:
-- dbt ls --select fct_orders+

select
    order_date,
    count(*) as order_count,
    sum(recognized_revenue) as recognized_revenue
from {{ ref('fct_orders') }}
group by order_date
order by order_date

