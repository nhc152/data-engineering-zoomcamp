select
    cast(order_id as varchar) as order_id,
    cast(customer_id as varchar) as customer_id,
    lower(trim(order_status)) as order_status,
    cast(order_date as date) as order_date,
    cast(captured_amount as decimal(12, 2)) as captured_amount
from {{ ref('raw_orders') }}

