{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='fail'
    )
}}

with orders as (
    select * from {{ ref('stg_ecommerce__orders') }}
    {% if is_incremental() %}
        where updated_at >= (
            select coalesce(max(updated_at), timestamp '1900-01-01') - interval '2 days'
            from {{ this }}
        )
    {% endif %}
),

items as (
    select * from {{ ref('int_order_items__aggregated_to_order') }}
),

payments as (
    select * from {{ ref('int_payments__aggregated_to_order') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.order_timestamp,
    orders.order_status,
    coalesce(items.item_line_count, 0) as item_line_count,
    coalesce(items.total_quantity, 0) as total_quantity,
    coalesce(items.gross_item_amount, 0) as gross_item_amount,
    coalesce(payments.captured_amount, 0) as captured_amount,
    coalesce(payments.refunded_amount, 0) as refunded_amount,
    case
        when orders.order_status in ('cancelled', 'refunded') then 0
        else coalesce(payments.captured_amount, 0)
    end as recognized_revenue,
    coalesce(payments.net_payment_amount, 0) as net_payment_amount,
    orders.updated_at,
    current_timestamp as mart_loaded_at
from orders
left join items
    on orders.order_id = items.order_id
left join payments
    on orders.order_id = payments.order_id

