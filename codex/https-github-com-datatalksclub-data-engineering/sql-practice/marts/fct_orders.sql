create or replace view marts.fct_orders as
with orders as (
    select * from staging.stg_orders
),

items_aggregated as (
    select
        order_id,
        count(*) as item_line_count,
        sum(quantity) as total_quantity,
        sum(gross_item_amount) as gross_item_amount
    from staging.stg_order_items
    group by order_id
),

payments_aggregated as (
    select
        order_id,
        sum(case when payment_status = 'captured' then amount else 0 end) as captured_amount,
        sum(case when payment_status = 'refunded' then amount else 0 end) as refunded_amount,
        sum(amount) as net_payment_amount
    from staging.stg_payments
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date_utc as order_date,
    orders.order_timestamp,
    orders.order_status,
    coalesce(items_aggregated.item_line_count, 0) as item_line_count,
    coalesce(items_aggregated.total_quantity, 0) as total_quantity,
    coalesce(items_aggregated.gross_item_amount, 0) as gross_item_amount,
    coalesce(payments_aggregated.captured_amount, 0) as captured_amount,
    coalesce(payments_aggregated.refunded_amount, 0) as refunded_amount,
    case
        when orders.order_status in ('cancelled', 'refunded') then 0
        else coalesce(payments_aggregated.captured_amount, 0)
    end as recognized_revenue,
    coalesce(payments_aggregated.net_payment_amount, 0) as net_payment_amount,
    orders.updated_at,
    orders.ingestion_timestamp
from orders
left join items_aggregated
    on orders.order_id = items_aggregated.order_id
left join payments_aggregated
    on orders.order_id = payments_aggregated.order_id;

