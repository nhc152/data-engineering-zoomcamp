select
    order_id,
    count(*) as item_line_count,
    sum(quantity) as total_quantity,
    sum(gross_item_amount) as gross_item_amount
from {{ ref('stg_ecommerce__order_items') }}
group by order_id

