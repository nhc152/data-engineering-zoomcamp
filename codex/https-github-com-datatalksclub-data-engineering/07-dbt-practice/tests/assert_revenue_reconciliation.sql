-- Expected: zero rows.
-- For non-cancelled/non-refunded orders, captured payment should match item total.

select
    order_id,
    order_status,
    gross_item_amount,
    captured_amount,
    captured_amount - gross_item_amount as difference
from {{ ref('fct_orders') }}
where order_status not in ('cancelled', 'refunded')
  and abs(captured_amount - gross_item_amount) > 0.01

