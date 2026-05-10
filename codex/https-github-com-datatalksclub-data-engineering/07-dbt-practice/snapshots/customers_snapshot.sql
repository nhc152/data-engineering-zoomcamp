{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='timestamp',
      updated_at='updated_at'
    )
}}

select
    customer_id,
    customer_name,
    email,
    country,
    customer_tier,
    updated_at
from {{ ref('stg_ecommerce__customers') }}

{% endsnapshot %}

