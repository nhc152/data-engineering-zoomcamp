-- Good pattern: filter on the partition column.
-- Trade-off: caller must specify date range; dashboard must expose date filter.

select
    customer_id,
    sum(recognized_revenue) as recognized_revenue
from `PROJECT.DATASET.fct_orders`
where order_date between date '2026-05-01' and date '2026-05-31'
group by customer_id
order by recognized_revenue desc;

