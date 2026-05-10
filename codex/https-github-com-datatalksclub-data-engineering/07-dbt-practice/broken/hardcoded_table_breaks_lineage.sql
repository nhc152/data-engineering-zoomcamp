-- Broken anti-pattern.
-- This bypasses `source()` and breaks dbt lineage/environment portability.

select
    order_id,
    customer_id,
    order_status
from raw.orders

