-- Fixed version using source().

select
    order_id,
    customer_id,
    order_status
from {{ source('ecommerce', 'orders') }}

