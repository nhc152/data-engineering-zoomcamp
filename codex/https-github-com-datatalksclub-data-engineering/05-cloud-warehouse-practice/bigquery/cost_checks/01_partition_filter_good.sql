-- Replace PROJECT_ID and MARTS_DATASET before running.
-- Cost expectation: lower bytes scanned because partition filter is present.
-- Run as dry run:
-- bq query --use_legacy_sql=false --dry_run '<paste this query>'

select
  order_date,
  sum(recognized_revenue) as recognized_revenue
from `PROJECT_ID.MARTS_DATASET.fct_orders`
where order_date between date '2026-05-01' and date '2026-05-03'
group by order_date;

