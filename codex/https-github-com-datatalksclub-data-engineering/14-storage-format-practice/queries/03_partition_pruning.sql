-- Query exact partition path.

select
    order_date,
    sum(recognized_revenue) as revenue
from read_parquet('data/lake/orders_partitioned/order_date=2026-05-01/*.parquet')
group by order_date;

-- Query all partitions. This is acceptable for month-level reports but bad for single-day dashboards.

select
    order_date,
    sum(recognized_revenue) as revenue
from read_parquet('data/lake/orders_partitioned/**/*.parquet')
group by order_date;

