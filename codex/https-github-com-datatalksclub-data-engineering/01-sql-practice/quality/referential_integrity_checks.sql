-- Expected result depends on policy. This lab intentionally includes O1009 with missing customer C999.

select
    orders.order_id,
    orders.customer_id
from marts.fct_orders as orders
left join marts.dim_customers as customers
    on orders.customer_id = customers.customer_id
where customers.customer_id is null;

-- Order items with missing products.
select
    items.order_item_id,
    items.order_id,
    items.product_id
from staging.stg_order_items as items
left join marts.dim_products as products
    on items.product_id = products.product_id
where products.product_id is null;

-- Payments with missing orders.
select
    payments.payment_id,
    payments.order_id
from staging.stg_payments as payments
left join staging.stg_orders as orders
    on payments.order_id = orders.order_id
where orders.order_id is null;

