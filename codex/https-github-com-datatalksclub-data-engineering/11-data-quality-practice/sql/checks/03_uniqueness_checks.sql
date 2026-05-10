-- Uniqueness checks.
-- Expected result for duplicate detail queries: zero rows.

select
    'duplicate_fct_orders_order_id' as check_id,
    order_id,
    count(*) as row_count
from marts.fct_orders
group by order_id
having count(*) > 1;

select
    'duplicate_dim_customers_customer_id' as check_id,
    customer_id,
    count(*) as row_count
from marts.dim_customers
group by customer_id
having count(*) > 1;

-- Summary check.
with duplicates as (
    select order_id
    from marts.fct_orders
    group by order_id
    having count(*) > 1
)

select
    'unique_fct_orders_order_id' as check_id,
    'marts.fct_orders' as table_name,
    count(*) as duplicate_key_count,
    case when count(*) = 0 then 'pass' else 'fail' end as status
from duplicates;

