-- Broken incremental pattern.
-- This misses updates to older orders because it filters by order_date only.

select *
from {{ ref('stg_ecommerce__orders') }}

{% if is_incremental() %}
where order_date > (
    select max(order_date)
    from {{ this }}
)
{% endif %}

