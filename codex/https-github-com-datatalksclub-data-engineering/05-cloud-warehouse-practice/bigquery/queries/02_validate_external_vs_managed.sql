-- Replace PROJECT_ID and RAW_DATASET before running.
-- Expected: external and managed counts match for each entity.

select
  'orders' as entity,
  (select count(*) from `PROJECT_ID.RAW_DATASET.ext_orders`) as external_rows,
  (select count(*) from `PROJECT_ID.RAW_DATASET.orders_raw`) as managed_rows
union all
select
  'payments',
  (select count(*) from `PROJECT_ID.RAW_DATASET.ext_payments`),
  (select count(*) from `PROJECT_ID.RAW_DATASET.payments_raw`);

