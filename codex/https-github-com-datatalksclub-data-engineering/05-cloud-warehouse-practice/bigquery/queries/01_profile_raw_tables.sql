-- Replace PROJECT_ID and RAW_DATASET before running.

select 'customers_raw' as table_name, count(*) as row_count from `PROJECT_ID.RAW_DATASET.customers_raw`
union all
select 'orders_raw', count(*) from `PROJECT_ID.RAW_DATASET.orders_raw`
union all
select 'order_items_raw', count(*) from `PROJECT_ID.RAW_DATASET.order_items_raw`
union all
select 'payments_raw', count(*) from `PROJECT_ID.RAW_DATASET.payments_raw`;

