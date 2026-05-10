-- Interview scenario:
-- The daily revenue dashboard is too high. Find out whether duplicate raw rows are causing it.

select
    order_id,
    count(*) as raw_order_rows
from raw.orders
group by order_id
having count(*) > 1;

select
    customer_id,
    count(*) as raw_customer_rows
from raw.customers
group by customer_id
having count(*) > 1;

select
    order_item_id,
    count(*) as raw_item_rows
from raw.order_items
group by order_item_id
having count(*) > 1;

