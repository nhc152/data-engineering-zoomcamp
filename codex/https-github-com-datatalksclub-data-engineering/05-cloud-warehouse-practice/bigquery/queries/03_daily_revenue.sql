-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Good query: uses partition filter.

select
  order_date,
  order_count,
  recognized_revenue
from `PROJECT_ID.MARTS_DATASET.mart_daily_revenue`
where order_date between date '2026-05-01' and date '2026-05-03'
order by order_date;

