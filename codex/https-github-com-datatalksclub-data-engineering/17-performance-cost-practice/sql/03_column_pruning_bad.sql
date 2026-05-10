-- Bad pattern: select * reads unnecessary columns.
-- On columnar warehouses, selecting fewer columns directly reduces scanned bytes.

select *
from `PROJECT.DATASET.fct_orders`
where order_date = date '2026-05-01';

