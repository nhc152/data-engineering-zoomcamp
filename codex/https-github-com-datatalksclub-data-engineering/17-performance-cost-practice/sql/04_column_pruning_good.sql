-- Good pattern: select only needed columns.
-- Trade-off: if downstream needs additional fields, query must be updated deliberately.

select
    order_id,
    customer_id,
    order_date,
    recognized_revenue
from `PROJECT.DATASET.fct_orders`
where order_date = date '2026-05-01';

