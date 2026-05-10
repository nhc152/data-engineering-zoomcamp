-- Solution: join SCD2 with business key and effective timestamp range.
-- This preserves fct_orders grain: one row per order.

select
    orders.order_id,
    orders.customer_id,
    customers.customer_sk,
    customers.customer_tier,
    orders.recognized_revenue
from fct_orders as orders
left join dim_customers_scd2 as customers
    on orders.customer_id = customers.customer_id
   and orders.order_timestamp >= customers.valid_from
   and orders.order_timestamp < coalesce(customers.valid_to, timestamp '9999-12-31');

-- Proof: row count should remain one row per order.
select
    count(*) as rows_after_join,
    count(distinct orders.order_id) as distinct_orders_after_join
from fct_orders as orders
left join dim_customers_scd2 as customers
    on orders.customer_id = customers.customer_id
   and orders.order_timestamp >= customers.valid_from
   and orders.order_timestamp < coalesce(customers.valid_to, timestamp '9999-12-31');

-- Why this works:
-- SCD2 dimension grain is one row per customer version.
-- The effective time condition selects the version valid when the order happened.

