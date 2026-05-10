create or replace view staging.stg_customers as
with cleaned as (
    select
        customer_id,
        nullif(trim(customer_name), '') as customer_name,
        lower(nullif(trim(email), '')) as email,
        nullif(trim(phone), '') as phone,
        lower(nullif(trim(customer_tier), '')) as customer_tier,
        upper(nullif(trim(country), '')) as country,
        created_at,
        updated_at,
        ingestion_timestamp
    from raw.customers
),

ranked as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from cleaned
    where customer_id is not null
)

select
    customer_id,
    customer_name,
    email,
    phone,
    customer_tier,
    country,
    created_at,
    updated_at,
    ingestion_timestamp
from ranked
where rn = 1;

