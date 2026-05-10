create or replace view marts.mart_daily_revenue as
select
    order_date,
    count(*) as order_count,
    count(distinct customer_id) as active_customer_count,
    sum(gross_item_amount) as gross_item_amount,
    sum(recognized_revenue) as recognized_revenue,
    sum(net_payment_amount) as net_payment_amount
from marts.fct_orders
group by order_date;

