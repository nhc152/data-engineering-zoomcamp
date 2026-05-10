-- Solution 02: Diagnose and fix join explosion.

-- Step 1: orders grain.
select
    count(*) as order_rows,
    count(distinct order_id) as distinct_orders
from staging.stg_orders;

-- Step 2: item grain. Multiple rows per order are expected.
select
    order_id,
    count(*) as item_rows
from staging.stg_order_items
group by order_id
having count(*) > 1;

-- Step 3: aggregate item-level table before joining to order-level table.
with item_totals as (
    select
        order_id,
        sum(quantity) as total_quantity,
        sum(gross_item_amount) as gross_item_amount
    from staging.stg_order_items
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date_utc,
    item_totals.total_quantity,
    item_totals.gross_item_amount
from staging.stg_orders as orders
left join item_totals
    on orders.order_id = item_totals.order_id;

