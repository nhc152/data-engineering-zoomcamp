-- Broken scenario: LTV ignores refunds.

select
    customers.customer_id,
    customers.customer_name,
    sum(orders.recognized_revenue) as lifetime_revenue_without_refunds
from dim_customers_current as customers
left join fct_orders as orders
    on customers.customer_id = orders.customer_id
group by
    customers.customer_id,
    customers.customer_name;

-- Diagnostic:
select
    customer_id,
    sum(recognized_revenue) as recognized_revenue,
    sum(net_revenue) as net_revenue,
    sum(recognized_revenue) - sum(net_revenue) as refund_impact
from fct_orders
group by customer_id
having sum(recognized_revenue) <> sum(net_revenue);

