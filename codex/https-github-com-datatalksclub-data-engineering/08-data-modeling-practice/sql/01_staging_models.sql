-- Staging models.
-- Goal: one source object -> one cleaned model.

create or replace view stg_customers as
select
    customer_id,
    nullif(trim(customer_name), '') as customer_name,
    lower(nullif(trim(email), '')) as email,
    upper(nullif(trim(country), '')) as country,
    lower(nullif(trim(customer_tier), '')) as customer_tier,
    updated_at
from raw_customers;

create or replace view stg_customer_tier_history as
select
    customer_id,
    lower(trim(customer_tier)) as customer_tier,
    valid_from,
    valid_to,
    case when valid_to is null then true else false end as is_current
from raw_customer_tier_history;

create or replace view stg_products as
select
    product_id,
    nullif(trim(product_name), '') as product_name,
    lower(nullif(trim(category), '')) as category,
    current_unit_price,
    updated_at
from raw_products;

create or replace view stg_orders as
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
    cast(order_timestamp as date) as order_date_utc,
    updated_at
from raw_orders;

create or replace view stg_order_items as
select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price as gross_item_amount
from raw_order_items;

create or replace view stg_payments as
select
    payment_id,
    order_id,
    lower(trim(payment_status)) as payment_status,
    amount,
    payment_timestamp
from raw_payments;

create or replace view stg_refunds as
select
    refund_id,
    order_id,
    payment_id,
    refund_amount,
    refund_timestamp
from raw_refunds;

create or replace view stg_events as
select
    event_id,
    customer_id,
    session_id,
    lower(trim(event_name)) as event_name,
    event_timestamp_utc,
    cast(event_timestamp_utc as date) as event_date_utc
from raw_events;

