-- Broken scenario: SCD2 join duplicates rows.
-- Symptom: fct_orders row count increases after joining customer tier history.

select
    orders.order_id,
    orders.customer_id,
    customers.customer_tier,
    orders.recognized_revenue
from fct_orders as orders
left join dim_customers_scd2 as customers
    on orders.customer_id = customers.customer_id;

-- Diagnostic query:
-- This should reveal row count growth if a customer has multiple SCD2 versions.
select
    'before_join' as step,
    count(*) as rows,
    count(distinct order_id) as distinct_orders
from fct_orders
union all
select
    'after_bad_scd2_join' as step,
    count(*) as rows,
    count(distinct orders.order_id) as distinct_orders
from fct_orders as orders
left join dim_customers_scd2 as customers
    on orders.customer_id = customers.customer_id;

