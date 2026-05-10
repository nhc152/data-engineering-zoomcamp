-- Broken scenario: product revenue calculated from order-level payment.
-- Symptom: product revenue is overstated when an order has multiple items.

select
    products.product_id,
    products.product_name,
    sum(orders.recognized_revenue) as product_revenue
from fct_orders as orders
left join fct_order_items as items
    on orders.order_id = items.order_id
left join dim_products as products
    on items.product_id = products.product_id
group by
    products.product_id,
    products.product_name;

-- Diagnostic query:
-- If an order has multiple items, order-level recognized_revenue repeats per item.
select
    orders.order_id,
    orders.recognized_revenue,
    count(items.order_item_id) as item_lines,
    orders.recognized_revenue * count(items.order_item_id) as repeated_revenue
from fct_orders as orders
left join fct_order_items as items
    on orders.order_id = items.order_id
group by
    orders.order_id,
    orders.recognized_revenue
having count(items.order_item_id) > 1;

