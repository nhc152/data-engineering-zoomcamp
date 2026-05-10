-- Broken scenario: two dashboards use different revenue definitions.

-- Dashboard A: uses recognized revenue from fct_orders.
select
    order_date_utc as reporting_date,
    sum(recognized_revenue) as dashboard_a_revenue
from fct_orders
group by order_date_utc;

-- Dashboard B: uses gross item amount and ignores cancellations/refunds.
select
    orders.order_date_utc as reporting_date,
    sum(items.gross_item_amount) as dashboard_b_revenue
from fct_orders as orders
left join fct_order_items as items
    on orders.order_id = items.order_id
group by orders.order_date_utc;

-- Diagnostic query:
select
    orders.order_date_utc as reporting_date,
    sum(orders.recognized_revenue) as recognized_revenue,
    sum(items.gross_item_amount) as gross_item_amount,
    sum(items.gross_item_amount) - sum(orders.recognized_revenue) as difference
from fct_orders as orders
left join fct_order_items as items
    on orders.order_id = items.order_id
group by orders.order_date_utc;

