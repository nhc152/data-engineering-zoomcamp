-- Business marts.

-- Grain: one row per UTC order date.
create or replace view mart_daily_revenue as
select
    order_date_utc as reporting_date,
    count(*) as order_count,
    count(distinct customer_id) as active_customer_count,
    sum(gross_item_amount) as gross_item_amount,
    sum(recognized_revenue) as recognized_revenue,
    sum(net_revenue) as net_revenue
from fct_orders
group by order_date_utc;

-- Grain: one row per customer.
create or replace view mart_customer_ltv as
select
    customers.customer_id,
    customers.customer_name,
    customers.customer_tier,
    customers.country,
    count(orders.order_id) as lifetime_order_count,
    sum(coalesce(orders.gross_item_amount, 0)) as lifetime_gross_item_amount,
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

-- Grain: one row per product.
-- Uses item-level fact, not order-level payments.
create or replace view mart_product_performance as
select
    products.product_id,
    products.product_name,
    products.category,
    count(distinct items.order_id) as order_count,
    sum(items.quantity) as units_sold,
    sum(items.gross_item_amount) as product_gross_revenue
from dim_products as products
left join fct_order_items as items
    on products.product_id = items.product_id
group by
    products.product_id,
    products.product_name,
    products.category;

-- Grain: one row per VN reporting date.
create or replace view mart_daily_active_users_vn as
select
    event_date_vn as reporting_date,
    count(distinct customer_id) as daily_active_users
from fct_events
where event_name in ('page_view', 'add_to_cart', 'checkout', 'purchase')
group by event_date_vn;

