-- Solution: calculate product revenue from item-level fact.
-- This preserves product grain and avoids repeating order-level payment.

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

-- Why this works:
-- Product performance grain is product.
-- Source fact is item-level, which contains product_id and item amount.
-- Order-level recognized_revenue is not repeated across product rows.

