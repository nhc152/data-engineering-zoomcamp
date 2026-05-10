-- Interview scenario:
-- Finance says order totals do not match payment totals. Identify mismatches.

with item_totals as (
    select
        order_id,
        sum(quantity * unit_price) as item_total
    from staging.stg_order_items
    group by order_id
),

payment_totals as (
    select
        order_id,
        sum(case when payment_status = 'captured' then amount else 0 end) as captured_total
    from staging.stg_payments
    group by order_id
)

select
    orders.order_id,
    orders.order_status,
    item_totals.item_total,
    payment_totals.captured_total,
    payment_totals.captured_total - item_totals.item_total as mismatch_amount
from staging.stg_orders as orders
left join item_totals
    on orders.order_id = item_totals.order_id
left join payment_totals
    on orders.order_id = payment_totals.order_id
where orders.order_status not in ('cancelled', 'refunded')
  and abs(coalesce(payment_totals.captured_total, 0) - coalesce(item_totals.item_total, 0)) > 0.01
order by abs(payment_totals.captured_total - item_totals.item_total) desc;

