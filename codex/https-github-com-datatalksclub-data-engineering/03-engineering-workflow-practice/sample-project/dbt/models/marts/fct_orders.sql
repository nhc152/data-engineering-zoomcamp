with orders as (
    select * from {{ ref('stg_orders') }}
),

final as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
        case
            when order_status in ('cancelled', 'refunded') then 0
            else amount
        end as recognized_revenue
    from orders
)

select * from final;

