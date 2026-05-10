select
    customer_id,
    customer_name,
    email,
    country,
    customer_tier,
    created_at,
    updated_at
from {{ ref('stg_ecommerce__customers') }}

