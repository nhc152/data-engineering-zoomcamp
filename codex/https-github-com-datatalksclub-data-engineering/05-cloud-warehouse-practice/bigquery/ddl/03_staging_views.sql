-- Replace PROJECT_ID, RAW_DATASET, and STAGING_DATASET before running.

create or replace view `PROJECT_ID.STAGING_DATASET.stg_customers` as
select
  customer_id,
  nullif(trim(customer_name), '') as customer_name,
  lower(nullif(trim(email), '')) as email,
  upper(nullif(trim(country), '')) as country,
  lower(nullif(trim(customer_tier), '')) as customer_tier,
  updated_at,
  loaded_at
from `PROJECT_ID.RAW_DATASET.customers_raw`;

create or replace view `PROJECT_ID.STAGING_DATASET.stg_orders` as
select
  order_id,
  customer_id,
  case
    when lower(trim(order_status)) in ('paid', 'shipped', 'completed') then lower(trim(order_status))
    when lower(trim(order_status)) in ('cancelled', 'canceled') then 'cancelled'
    when lower(trim(order_status)) = 'refunded' then 'refunded'
    else 'unknown'
  end as order_status,
  order_timestamp,
  date(order_timestamp) as order_date,
  updated_at,
  loaded_at
from `PROJECT_ID.RAW_DATASET.orders_raw`;

create or replace view `PROJECT_ID.STAGING_DATASET.stg_order_items` as
select
  order_item_id,
  order_id,
  product_id,
  quantity,
  unit_price,
  quantity * unit_price as gross_item_amount,
  loaded_at
from `PROJECT_ID.RAW_DATASET.order_items_raw`;

create or replace view `PROJECT_ID.STAGING_DATASET.stg_payments` as
select
  payment_id,
  order_id,
  lower(trim(payment_status)) as payment_status,
  amount,
  payment_timestamp,
  date(payment_timestamp) as payment_date,
  loaded_at
from `PROJECT_ID.RAW_DATASET.payments_raw`;

