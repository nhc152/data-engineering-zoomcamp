select
    order_date,
    count(*) as order_count,
    count(distinct customer_id) as active_customer_count,
    sum(gross_item_amount) as gross_item_amount,
    sum(recognized_revenue) as recognized_revenue,
    sum(net_payment_amount) as net_payment_amount,
    current_timestamp as mart_loaded_at
from {{ ref('fct_orders') }}
group by order_date

