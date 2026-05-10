-- Quality checks for grain and metric consistency.

-- Expected: zero rows. fct_orders must be one row per order.
select
    order_id,
    count(*) as row_count
from fct_orders
group by order_id
having count(*) > 1;

-- Expected: zero rows. fct_order_items must be one row per order item.
select
    order_item_id,
    count(*) as row_count
from fct_order_items
group by order_item_id
having count(*) > 1;

-- Expected: zero rows unless orphan facts are allowed.
select
    orders.order_id,
    orders.customer_id
from fct_orders as orders
left join dim_customers_current as customers
    on orders.customer_id = customers.customer_id
where customers.customer_id is null;

-- Diagnostic: row count should not change after joining current customer dimension.
select
    'before_join' as step,
    count(*) as row_count,
    count(distinct order_id) as distinct_orders
from fct_orders
union all
select
    'after_current_customer_join' as step,
    count(*) as row_count,
    count(distinct orders.order_id) as distinct_orders
from fct_orders as orders
left join dim_customers_current as customers
    on orders.customer_id = customers.customer_id;

