-- Solution 03: Safer incremental load with updated_at watermark and upsert.

insert into incremental.fct_orders_merge (
    order_id,
    customer_id,
    order_date,
    order_status,
    paid_amount,
    updated_at,
    loaded_at
)
select
    order_id,
    customer_id,
    order_date,
    order_status,
    recognized_revenue as paid_amount,
    updated_at,
    now() as loaded_at
from marts.fct_orders
where updated_at >= (
    select watermark_timestamp - interval '2 days'
    from incremental.pipeline_watermarks
    where pipeline_name = 'orders_pipeline'
)
on conflict (order_id) do update set
    customer_id = excluded.customer_id,
    order_date = excluded.order_date,
    order_status = excluded.order_status,
    paid_amount = excluded.paid_amount,
    updated_at = excluded.updated_at,
    loaded_at = now();

update incremental.pipeline_watermarks
set
    watermark_timestamp = (
        select max(updated_at)
        from incremental.fct_orders_merge
    ),
    updated_at = now()
where pipeline_name = 'orders_pipeline';

