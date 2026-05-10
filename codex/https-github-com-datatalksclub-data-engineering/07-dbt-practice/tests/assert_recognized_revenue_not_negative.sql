-- Expected: zero rows.

select
    order_id,
    recognized_revenue
from {{ ref('fct_orders') }}
where order_status != 'refunded'
  and recognized_revenue < 0

