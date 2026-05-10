-- DuckDB query examples.

select
    order_date,
    sum(recognized_revenue) as revenue
from read_csv_auto('data/raw/orders.csv')
where order_date between '2026-05-01' and '2026-05-07'
group by order_date;

select
    order_date,
    sum(recognized_revenue) as revenue
from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
where order_date between '2026-05-01' and '2026-05-07'
group by order_date;

