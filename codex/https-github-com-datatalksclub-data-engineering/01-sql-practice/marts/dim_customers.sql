create or replace view marts.dim_customers as
select
    customer_id,
    customer_name,
    email,
    phone,
    customer_tier,
    country,
    created_at,
    updated_at
from staging.stg_customers;

