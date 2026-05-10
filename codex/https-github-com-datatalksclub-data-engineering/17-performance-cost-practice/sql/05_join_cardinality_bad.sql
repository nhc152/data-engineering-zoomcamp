-- Bad pattern: join order-level payment to item-level rows, then sum payment.
-- This duplicates revenue for multi-item orders.

select
    orders.order_date,
    sum(payments.amount) as revenue
from `PROJECT.DATASET.orders` as orders
left join `PROJECT.DATASET.order_items` as order_items
    on orders.order_id = order_items.order_id
left join `PROJECT.DATASET.payments` as payments
    on orders.order_id = payments.order_id
where orders.order_status in ('paid', 'completed', 'shipped')
group by orders.order_date;

