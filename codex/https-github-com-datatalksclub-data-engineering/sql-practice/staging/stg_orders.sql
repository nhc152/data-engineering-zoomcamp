create or replace view staging.stg_orders as
with cleaned as (
    select
        order_id,
        customer_id,
        lower(trim(order_status)) as order_status,
        order_timestamp,
        (order_timestamp at time zone 'UTC')::date as order_date_utc,
        updated_at,
        source_timezone,
        ingestion_timestamp
    from raw.orders
),

standardized as (
    select
        *,
        case
            when order_status in ('paid', 'shipped', 'completed') then order_status
            when order_status in ('cancelled', 'canceled') then 'cancelled'
            when order_status = 'refunded' then 'refunded'
            else 'unknown'
        end as normalized_order_status
    from cleaned
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from standardized
    where order_id is not null
)

select
    order_id,
    customer_id,
    normalized_order_status as order_status,
    order_timestamp,
    order_date_utc,
    updated_at,
    source_timezone,
    ingestion_timestamp
from ranked
where rn = 1;

