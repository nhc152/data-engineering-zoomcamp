-- Validity checks.

-- Accepted values for order_status.
select
    'accepted_values_order_status' as check_id,
    order_status,
    count(*) as row_count
from marts.fct_orders
where order_status not in ('pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded')
group by order_status;

-- Revenue should not be negative for recognized revenue.
select
    'valid_recognized_revenue_non_negative' as check_id,
    order_id,
    order_status,
    recognized_revenue
from marts.fct_orders
where recognized_revenue < 0;

-- Required fields should not be null.
select
    'not_null_fct_orders_required_fields' as check_id,
    order_id,
    customer_id,
    order_date
from marts.fct_orders
where order_id is null
   or customer_id is null
   or order_date is null;

