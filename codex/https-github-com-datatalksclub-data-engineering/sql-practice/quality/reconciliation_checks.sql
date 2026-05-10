-- Reconcile item totals, payment totals, and fact totals by order.

with item_totals as (
    select
        order_id,
        sum(gross_item_amount) as item_total
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
    coalesce(item_totals.item_total, 0) as item_total,
    coalesce(payment_totals.captured_total, 0) as captured_total,
    coalesce(payment_totals.captured_total, 0) - coalesce(item_totals.item_total, 0) as difference
from staging.stg_orders as orders
left join item_totals
    on orders.order_id = item_totals.order_id
left join payment_totals
    on orders.order_id = payment_totals.order_id
where orders.order_status not in ('cancelled', 'refunded')
  and abs(coalesce(payment_totals.captured_total, 0) - coalesce(item_totals.item_total, 0)) > 0.01;

-- Reconcile daily revenue from fact to mart.
select
    fact.order_date,
    fact.revenue_from_fact,
    mart.recognized_revenue as revenue_from_mart,
    fact.revenue_from_fact - mart.recognized_revenue as difference
from (
    select
        order_date,
        sum(recognized_revenue) as revenue_from_fact
    from marts.fct_orders
    group by order_date
) as fact
left join marts.mart_daily_revenue as mart
    on fact.order_date = mart.order_date
where abs(fact.revenue_from_fact - mart.recognized_revenue) > 0.01;

