-- Replace PROJECT_ID and RAW_DATASET before running.
-- Managed tables copy data into BigQuery storage.

create or replace table `PROJECT_ID.RAW_DATASET.customers_raw` as
select
  cast(customer_id as string) as customer_id,
  cast(customer_name as string) as customer_name,
  cast(email as string) as email,
  cast(country as string) as country,
  cast(customer_tier as string) as customer_tier,
  timestamp(updated_at) as updated_at,
  current_timestamp() as loaded_at
from `PROJECT_ID.RAW_DATASET.ext_customers`;

create or replace table `PROJECT_ID.RAW_DATASET.orders_raw` as
select
  cast(order_id as string) as order_id,
  cast(customer_id as string) as customer_id,
  cast(order_status as string) as order_status,
  timestamp(order_timestamp) as order_timestamp,
  timestamp(updated_at) as updated_at,
  current_timestamp() as loaded_at
from `PROJECT_ID.RAW_DATASET.ext_orders`;

create or replace table `PROJECT_ID.RAW_DATASET.order_items_raw` as
select
  cast(order_item_id as string) as order_item_id,
  cast(order_id as string) as order_id,
  cast(product_id as string) as product_id,
  cast(quantity as int64) as quantity,
  cast(unit_price as numeric) as unit_price,
  current_timestamp() as loaded_at
from `PROJECT_ID.RAW_DATASET.ext_order_items`;

create or replace table `PROJECT_ID.RAW_DATASET.payments_raw` as
select
  cast(payment_id as string) as payment_id,
  cast(order_id as string) as order_id,
  cast(payment_status as string) as payment_status,
  cast(amount as numeric) as amount,
  timestamp(payment_timestamp) as payment_timestamp,
  current_timestamp() as loaded_at
from `PROJECT_ID.RAW_DATASET.ext_payments`;

