select
    order_date,
    count(*) as order_count,
    count(distinct customer_id) as active_customer_count,
    sum(recognized_revenue) as recognized_revenue
from {{ ref('fct_orders') }}
group by order_date

