-- Solution: LTV should use net_revenue if refunds matter to the business.

select
    customers.customer_id,
    customers.customer_name,
    customers.customer_tier,
    customers.country,
    count(orders.order_id) as lifetime_order_count,
    sum(coalesce(orders.net_revenue, 0)) as lifetime_net_revenue,
    min(orders.order_date_utc) as first_order_date,
    max(orders.order_date_utc) as latest_order_date
from dim_customers_current as customers
left join fct_orders as orders
    on customers.customer_id = orders.customer_id
group by
    customers.customer_id,
    customers.customer_name,
    customers.customer_tier,
    customers.country;

-- Why this works:
-- Customer LTV grain is one row per customer.
-- `net_revenue` reflects refund impact.
-- Cancelled/refunded behavior is centralized in fct_orders.

