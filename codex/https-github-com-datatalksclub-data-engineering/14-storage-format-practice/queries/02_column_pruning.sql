-- Bad: select all columns when only three are needed.

select *
from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
where order_date = '2026-05-01';

-- Better: select only columns needed by downstream report.

select
    order_id,
    customer_id,
    recognized_revenue
from read_parquet('data/lake/orders_parquet_snappy/orders.parquet')
where order_date = '2026-05-01';

