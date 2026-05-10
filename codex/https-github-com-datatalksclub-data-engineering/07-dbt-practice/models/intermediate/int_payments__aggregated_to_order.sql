select
    order_id,
    sum(case when payment_status = 'captured' then amount else 0 end) as captured_amount,
    sum(case when payment_status = 'refunded' then amount else 0 end) as refunded_amount,
    sum(amount) as net_payment_amount
from {{ ref('stg_ecommerce__payments') }}
group by order_id

