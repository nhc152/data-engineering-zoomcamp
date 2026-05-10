-- Fixed incremental pattern using updated_at and a lookback window.

select *
from {{ ref('stg_ecommerce__orders') }}

{% if is_incremental() %}
where updated_at >= (
    select coalesce(max(updated_at), timestamp '1900-01-01') - interval '2 days'
    from {{ this }}
)
{% endif %}

