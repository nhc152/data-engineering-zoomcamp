create or replace view staging.stg_payments as
with cleaned as (
    select
        payment_id,
        order_id,
        lower(trim(payment_method)) as payment_method,
        lower(trim(payment_status)) as payment_status,
        amount,
        payment_timestamp,
        (payment_timestamp at time zone 'UTC')::date as payment_date_utc,
        updated_at,
        ingestion_timestamp
    from raw.payments
),

ranked as (
    select
        *,
        row_number() over (
            partition by payment_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from cleaned
    where payment_id is not null
)

select
    payment_id,
    order_id,
    payment_method,
    payment_status,
    amount,
    payment_timestamp,
    payment_date_utc,
    updated_at,
    ingestion_timestamp
from ranked
where rn = 1;

