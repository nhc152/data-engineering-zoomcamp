-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Bad query: select * reads unnecessary columns.

select *
from `PROJECT_ID.MARTS_DATASET.fct_orders`
where order_date = date '2026-05-01';

