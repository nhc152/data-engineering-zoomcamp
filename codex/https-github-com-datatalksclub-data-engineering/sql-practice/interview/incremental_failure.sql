-- Broken incremental query:
-- This misses late-arriving data because it filters by order_date instead of updated_at.

select
    order_id,
    customer_id,
    order_date,
    order_status,
    recognized_revenue,
    updated_at
from marts.fct_orders
where order_date > (
    select watermark_timestamp::date
    from incremental.pipeline_watermarks
    where pipeline_name = 'orders_pipeline'
);

