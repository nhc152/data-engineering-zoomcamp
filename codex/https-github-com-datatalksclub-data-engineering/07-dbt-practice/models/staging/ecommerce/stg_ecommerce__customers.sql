with source as (
    select * from {{ source('ecommerce', 'customers') }}
),

cleaned as (
    select
        customer_id,
        nullif(trim(customer_name), '') as customer_name,
        lower(nullif(trim(email), '')) as email,
        upper(nullif(trim(country), '')) as country,
        lower(nullif(trim(customer_tier), '')) as customer_tier,
        created_at,
        updated_at,
        loaded_at
    from source
),

ranked as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by updated_at desc, loaded_at desc
        ) as rn
    from cleaned
    where customer_id is not null
)

select
    customer_id,
    customer_name,
    email,
    country,
    customer_tier,
    created_at,
    updated_at,
    loaded_at
from ranked
where rn = 1

