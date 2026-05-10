with orders as (
    select * from {{ ref('stg_orders') }}
),

final as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
<<<<<<< HEAD
        case
            when order_status = 'cancelled' then 0
            else amount
        end as recognized_revenue
=======
        case
            when order_status = 'refunded' then 0
            else amount
        end as revenue
>>>>>>> feature/refund-rule
    from orders
)

select * from final;

