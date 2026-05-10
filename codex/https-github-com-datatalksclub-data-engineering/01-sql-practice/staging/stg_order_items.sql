create or replace view staging.stg_order_items as
with cleaned as (
    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        quantity * unit_price as gross_item_amount,
        updated_at,
        ingestion_timestamp
    from raw.order_items
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_item_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from cleaned
    where order_item_id is not null
)

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    gross_item_amount,
    updated_at,
    ingestion_timestamp
from ranked
where rn = 1;

