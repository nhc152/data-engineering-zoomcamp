with source as (
    select
        order_id,
        customer_id,
        lower(trim(order_status)) as order_status,
        cast(order_date as date) as order_date,
        cast(amount as numeric(12, 2)) as amount
    from raw.orders
),

final as (
    select
        order_id,
        customer_id,
        order_status,
        order_date,
        amount
    from source
)

select * from final;

