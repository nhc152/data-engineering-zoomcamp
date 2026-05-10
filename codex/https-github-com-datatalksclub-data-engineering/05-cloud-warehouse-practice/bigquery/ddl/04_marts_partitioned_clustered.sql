-- Replace PROJECT_ID, STAGING_DATASET, and MARTS_DATASET before running.

create or replace table `PROJECT_ID.MARTS_DATASET.fct_orders`
partition by order_date
cluster by customer_id, order_status
as
with orders as (
  select * from `PROJECT_ID.STAGING_DATASET.stg_orders`
),

items_aggregated as (
  select
    order_id,
    count(*) as item_line_count,
    sum(quantity) as total_quantity,
    sum(gross_item_amount) as gross_item_amount
  from `PROJECT_ID.STAGING_DATASET.stg_order_items`
  group by order_id
),

payments_aggregated as (
  select
    order_id,
    sum(if(payment_status = 'captured', amount, 0)) as captured_amount,
    sum(if(payment_status = 'refunded', amount, 0)) as refunded_amount,
    sum(amount) as net_payment_amount
  from `PROJECT_ID.STAGING_DATASET.stg_payments`
  group by order_id
)

select
  orders.order_id,
  orders.customer_id,
  orders.order_date,
  orders.order_timestamp,
  orders.order_status,
  coalesce(items_aggregated.item_line_count, 0) as item_line_count,
  coalesce(items_aggregated.total_quantity, 0) as total_quantity,
  coalesce(items_aggregated.gross_item_amount, 0) as gross_item_amount,
  coalesce(payments_aggregated.captured_amount, 0) as captured_amount,
  coalesce(payments_aggregated.refunded_amount, 0) as refunded_amount,
  case
    when orders.order_status in ('cancelled', 'refunded') then 0
    else coalesce(payments_aggregated.captured_amount, 0)
  end as recognized_revenue,
  coalesce(payments_aggregated.net_payment_amount, 0) as net_payment_amount,
  orders.updated_at,
  current_timestamp() as mart_loaded_at
from orders
left join items_aggregated
  on orders.order_id = items_aggregated.order_id
left join payments_aggregated
  on orders.order_id = payments_aggregated.order_id;

create or replace table `PROJECT_ID.MARTS_DATASET.mart_daily_revenue`
partition by order_date
as
select
  order_date,
  count(*) as order_count,
  count(distinct customer_id) as active_customer_count,
  sum(gross_item_amount) as gross_item_amount,
  sum(recognized_revenue) as recognized_revenue,
  sum(net_payment_amount) as net_payment_amount,
  current_timestamp() as mart_loaded_at
from `PROJECT_ID.MARTS_DATASET.fct_orders`
group by order_date;

