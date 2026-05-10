create or replace view marts.dim_products as
with ranked as (
    select
        product_id,
        trim(product_name) as product_name,
        lower(trim(category)) as category,
        unit_price,
        is_active,
        updated_at,
        ingestion_timestamp,
        row_number() over (
            partition by product_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from raw.products
    where product_id is not null
)

select
    product_id,
    product_name,
    category,
    unit_price,
    is_active,
    updated_at
from ranked
where rn = 1;

