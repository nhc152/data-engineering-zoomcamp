select
    order_id,
    customer_id,
    order_date,
    order_status,
    captured_amount,
    case
        when order_status in ('cancelled', 'refunded') then 0
        else captured_amount
    end as recognized_revenue
from {{ ref('stg_orders') }}

