-- Demonstrates a naive append load.
-- Run this twice and it will duplicate rows because there is no unique key protection.

insert into incremental.fct_orders_append (
    order_id,
    customer_id,
    order_date,
    order_status,
    paid_amount,
    updated_at
)
select
    order_id,
    customer_id,
    order_date,
    order_status,
    recognized_revenue as paid_amount,
    updated_at
from marts.fct_orders
where updated_at > (
    select watermark_timestamp
    from incremental.pipeline_watermarks
    where pipeline_name = 'orders_pipeline'
);

select
    order_id,
    count(*) as row_count
from incremental.fct_orders_append
group by order_id
having count(*) > 1;

