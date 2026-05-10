-- Expected: 5 rows after a clean lab run.
select
    'row_count' as check_name,
    count(*) as actual_value
from raw.orders;

-- Expected: zero rows.
select
    'duplicate_order_id' as check_name,
    order_id,
    count(*) as row_count
from raw.orders
group by order_id
having count(*) > 1;

-- Expected: zero rows.
select
    'invalid_status' as check_name,
    order_id,
    order_status
from raw.orders
where order_status not in ('paid', 'cancelled', 'refunded');

-- Expected: one row per date with stable totals.
select
    order_date,
    count(*) as order_count,
    sum(order_amount) as total_amount
from raw.orders
group by order_date
order by order_date;

