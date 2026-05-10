-- Dimension models.

-- Grain: one row per current customer.
create or replace view dim_customers_current as
select
    customer_id,
    customer_name,
    email,
    country,
    customer_tier,
    updated_at
from stg_customers;

-- Grain: one row per customer version.
-- In production, customer_sk should be a stable generated surrogate key.
create or replace view dim_customers_scd2 as
select
    concat(customer_id, '|', cast(valid_from as text)) as customer_sk,
    customer_id,
    customer_tier,
    valid_from,
    valid_to,
    is_current
from stg_customer_tier_history;

-- Grain: one row per product.
create or replace view dim_products as
select
    product_id,
    product_name,
    category,
    current_unit_price,
    updated_at
from stg_products;

