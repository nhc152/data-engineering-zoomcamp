-- Referential integrity checks.
-- Expected result depends on business policy. Missing customer may be allowed only for guest checkout.

select
    'fk_fct_orders_customer_id' as check_id,
    orders.order_id,
    orders.customer_id
from marts.fct_orders as orders
left join marts.dim_customers as customers
    on orders.customer_id = customers.customer_id
where customers.customer_id is null;

-- Summary version.
with missing_customers as (
    select orders.order_id
    from marts.fct_orders as orders
    left join marts.dim_customers as customers
        on orders.customer_id = customers.customer_id
    where customers.customer_id is null
)

select
    'fk_fct_orders_customer_id_summary' as check_id,
    count(*) as missing_customer_count,
    case when count(*) = 0 then 'pass' else 'fail_or_review_policy' end as status
from missing_customers;

