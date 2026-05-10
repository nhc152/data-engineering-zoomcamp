-- Broken query:
-- This query duplicates order-level payment amount after joining item-level rows.

select
    orders.order_date_utc as order_date,
    sum(payments.amount) as revenue
from staging.stg_orders as orders
left join staging.stg_order_items as items
    on orders.order_id = items.order_id
left join staging.stg_payments as payments
    on orders.order_id = payments.order_id
where orders.order_status in ('paid', 'shipped', 'completed')
  and payments.payment_status = 'captured'
group by orders.order_date_utc
order by orders.order_date_utc;

