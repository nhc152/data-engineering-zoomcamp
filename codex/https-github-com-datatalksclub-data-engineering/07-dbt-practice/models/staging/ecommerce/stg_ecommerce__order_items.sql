select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price as gross_item_amount,
    loaded_at
from {{ source('ecommerce', 'order_items') }}
where order_item_id is not null

