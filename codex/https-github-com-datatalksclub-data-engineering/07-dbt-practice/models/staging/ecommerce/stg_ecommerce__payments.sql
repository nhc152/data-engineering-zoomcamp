select
    payment_id,
    order_id,
    lower(trim(payment_status)) as payment_status,
    amount,
    payment_timestamp,
    cast(payment_timestamp as date) as payment_date,
    updated_at,
    loaded_at
from {{ source('ecommerce', 'payments') }}
where payment_id is not null

