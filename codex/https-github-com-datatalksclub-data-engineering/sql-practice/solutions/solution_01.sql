-- Solution 01: Correct daily revenue without join explosion.
-- Keep one row per order before aggregating daily revenue.

select
    order_date,
    sum(recognized_revenue) as recognized_revenue
from marts.fct_orders
group by order_date
order by order_date;

-- Diagnostic: prove fct_orders has one row per order.
select
    order_id,
    count(*) as row_count
from marts.fct_orders
group by order_id
having count(*) > 1;

