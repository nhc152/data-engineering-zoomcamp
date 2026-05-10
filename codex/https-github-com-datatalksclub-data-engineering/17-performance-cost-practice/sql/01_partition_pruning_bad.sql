-- Bad pattern: no partition filter.
-- On a large partitioned fact table, this scans every partition.
-- Replace PROJECT.DATASET.TABLE with your own table.

select
    customer_id,
    sum(recognized_revenue) as recognized_revenue
from `PROJECT.DATASET.fct_orders`
group by customer_id
order by recognized_revenue desc;

