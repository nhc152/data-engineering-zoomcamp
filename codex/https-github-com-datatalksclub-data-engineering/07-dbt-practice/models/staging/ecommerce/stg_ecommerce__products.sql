select
    product_id,
    nullif(trim(product_name), '') as product_name,
    lower(nullif(trim(category), '')) as category,
    unit_price,
    is_active,
    updated_at,
    loaded_at
from {{ source('ecommerce', 'products') }}
where product_id is not null

