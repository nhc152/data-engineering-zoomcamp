-- Expected result for each check: zero rows.

-- Raw duplicate customers.
select
    'raw.customers duplicate customer_id' as check_name,
    customer_id,
    count(*) as row_count
from raw.customers
group by customer_id
having count(*) > 1;

-- Staging customers should be unique.
select
    'staging.stg_customers duplicate customer_id' as check_name,
    customer_id,
    count(*) as row_count
from staging.stg_customers
group by customer_id
having count(*) > 1;

-- Raw duplicate orders.
select
    'raw.orders duplicate order_id' as check_name,
    order_id,
    count(*) as row_count
from raw.orders
group by order_id
having count(*) > 1;

-- Fact orders should be unique.
select
    'marts.fct_orders duplicate order_id' as check_name,
    order_id,
    count(*) as row_count
from marts.fct_orders
group by order_id
having count(*) > 1;

-- Duplicate source events.
select
    'raw.events duplicate event_id' as check_name,
    event_id,
    count(*) as row_count
from raw.events
group by event_id
having count(*) > 1;

