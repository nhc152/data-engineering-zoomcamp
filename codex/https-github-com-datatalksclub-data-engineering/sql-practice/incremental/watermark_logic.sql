-- Watermark diagnostics.
-- The current watermark controls which source changes are included in the next incremental run.

select *
from incremental.pipeline_watermarks
where pipeline_name = 'orders_pipeline';

-- Records newer than the current watermark.
select
    order_id,
    customer_id,
    order_status,
    order_date,
    updated_at,
    ingestion_timestamp
from marts.fct_orders
where updated_at > (
    select watermark_timestamp
    from incremental.pipeline_watermarks
    where pipeline_name = 'orders_pipeline'
)
order by updated_at;

-- Safer lookback strategy for late updates.
select
    order_id,
    customer_id,
    order_status,
    order_date,
    updated_at,
    ingestion_timestamp
from marts.fct_orders
where updated_at >= (
    select watermark_timestamp - interval '2 days'
    from incremental.pipeline_watermarks
    where pipeline_name = 'orders_pipeline'
)
order by updated_at;

