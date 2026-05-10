create or replace view marts.mart_customer_ltv as
select
    customers.customer_id,
    customers.customer_name,
    customers.customer_tier,
    customers.country,
    count(orders.order_id) as lifetime_order_count,
    sum(coalesce(orders.recognized_revenue, 0)) as lifetime_recognized_revenue,
    min(orders.order_date) as first_order_date,
    max(orders.order_date) as latest_order_date
from marts.dim_customers as customers
left join marts.fct_orders as orders
    on customers.customer_id = orders.customer_id
group by
    customers.customer_id,
    customers.customer_name,
    customers.customer_tier,
    customers.country;

