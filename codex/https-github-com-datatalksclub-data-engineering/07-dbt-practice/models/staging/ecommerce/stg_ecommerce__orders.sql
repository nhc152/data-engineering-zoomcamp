with source as (
    select * from {{ source('ecommerce', 'orders') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        {{ normalize_order_status('order_status') }} as order_status,
        order_timestamp,
        cast(order_timestamp as date) as order_date,
        updated_at,
        loaded_at
    from source
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc, loaded_at desc
        ) as rn
    from cleaned
    where order_id is not null
)

select
    order_id,
    customer_id,
    order_status,
    order_timestamp,
    order_date,
    updated_at,
    loaded_at
from ranked
where rn = 1

