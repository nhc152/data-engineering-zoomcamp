-- Good pattern: aggregate payments to order grain before joining.
-- Trade-off: product-level revenue should be calculated from item-level facts, not order-level payment.

with payments_by_order as (
    select
        order_id,
        sum(amount) as paid_amount
    from `PROJECT.DATASET.payments`
    where payment_status = 'captured'
    group by order_id
)

select
    orders.order_date,
    sum(payments_by_order.paid_amount) as revenue
from `PROJECT.DATASET.orders` as orders
left join payments_by_order
    on orders.order_id = payments_by_order.order_id
where orders.order_status in ('paid', 'completed', 'shipped')
group by orders.order_date;

