-- Fact models.

-- Grain: one row per payment transaction.
create or replace view fct_payments as
select
    payment_id,
    order_id,
    payment_status,
    amount,
    payment_timestamp
from stg_payments;

-- Grain: one row per order item.
create or replace view fct_order_items as
select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    gross_item_amount
from stg_order_items;

-- Grain: one row per order.
-- Child tables are aggregated to order grain before joining.
create or replace view fct_orders as
with items_aggregated as (
    select
        order_id,
        count(*) as item_line_count,
        sum(quantity) as total_quantity,
        sum(gross_item_amount) as gross_item_amount
    from stg_order_items
    group by order_id
),

payments_aggregated as (
    select
        order_id,
        sum(case when payment_status = 'captured' then amount else 0 end) as captured_amount,
        sum(case when payment_status = 'refunded' then abs(amount) else 0 end) as refunded_amount
    from stg_payments
    group by order_id
),

refunds_aggregated as (
    select
        order_id,
        sum(refund_amount) as explicit_refund_amount
    from stg_refunds
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date_utc,
    orders.order_timestamp,
    orders.order_status,
    coalesce(items_aggregated.item_line_count, 0) as item_line_count,
    coalesce(items_aggregated.total_quantity, 0) as total_quantity,
    coalesce(items_aggregated.gross_item_amount, 0) as gross_item_amount,
    coalesce(payments_aggregated.captured_amount, 0) as captured_amount,
    coalesce(payments_aggregated.refunded_amount, 0)
        + coalesce(refunds_aggregated.explicit_refund_amount, 0) as refunded_amount,
    case
        when orders.order_status in ('cancelled', 'refunded') then 0
        else coalesce(payments_aggregated.captured_amount, 0)
    end as recognized_revenue,
    coalesce(payments_aggregated.captured_amount, 0)
        - coalesce(payments_aggregated.refunded_amount, 0)
        - coalesce(refunds_aggregated.explicit_refund_amount, 0) as net_revenue
from stg_orders as orders
left join items_aggregated
    on orders.order_id = items_aggregated.order_id
left join payments_aggregated
    on orders.order_id = payments_aggregated.order_id
left join refunds_aggregated
    on orders.order_id = refunds_aggregated.order_id;

-- Grain: one row per deduplicated event.
create or replace view fct_events as
select
    event_id,
    customer_id,
    session_id,
    event_name,
    event_timestamp_utc,
    event_date_utc,
    -- Example local date for Vietnam reporting.
    cast(event_timestamp_utc + interval '7 hours' as date) as event_date_vn
from stg_events;

