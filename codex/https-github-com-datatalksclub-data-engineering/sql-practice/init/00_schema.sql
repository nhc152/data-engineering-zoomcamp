drop schema if exists raw cascade;
drop schema if exists staging cascade;
drop schema if exists marts cascade;
drop schema if exists quality cascade;
drop schema if exists incremental cascade;

create schema raw;
create schema staging;
create schema marts;
create schema quality;
create schema incremental;

create table raw.customers (
    raw_customer_row_id bigserial primary key,
    customer_id text,
    customer_name text,
    email text,
    phone text,
    customer_tier text,
    country text,
    created_at timestamptz,
    updated_at timestamptz,
    ingestion_timestamp timestamptz default now()
);

create table raw.products (
    raw_product_row_id bigserial primary key,
    product_id text,
    product_name text,
    category text,
    unit_price numeric(12, 2),
    is_active boolean,
    updated_at timestamptz,
    ingestion_timestamp timestamptz default now()
);

create table raw.orders (
    raw_order_row_id bigserial primary key,
    order_id text,
    customer_id text,
    order_status text,
    order_timestamp timestamptz,
    updated_at timestamptz,
    source_timezone text,
    ingestion_timestamp timestamptz default now()
);

create table raw.order_items (
    raw_order_item_row_id bigserial primary key,
    order_item_id text,
    order_id text,
    product_id text,
    quantity integer,
    unit_price numeric(12, 2),
    updated_at timestamptz,
    ingestion_timestamp timestamptz default now()
);

create table raw.payments (
    raw_payment_row_id bigserial primary key,
    payment_id text,
    order_id text,
    payment_method text,
    payment_status text,
    amount numeric(12, 2),
    payment_timestamp timestamptz,
    updated_at timestamptz,
    ingestion_timestamp timestamptz default now()
);

create table raw.events (
    raw_event_row_id bigserial primary key,
    event_id text,
    customer_id text,
    session_id text,
    event_name text,
    event_timestamp timestamptz,
    payload jsonb,
    ingestion_timestamp timestamptz default now()
);

create table incremental.pipeline_watermarks (
    pipeline_name text primary key,
    watermark_timestamp timestamptz not null,
    updated_at timestamptz default now()
);

create table incremental.fct_orders_append (
    order_id text,
    customer_id text,
    order_date date,
    order_status text,
    paid_amount numeric(12, 2),
    updated_at timestamptz,
    loaded_at timestamptz default now()
);

create table incremental.fct_orders_merge (
    order_id text primary key,
    customer_id text,
    order_date date,
    order_status text,
    paid_amount numeric(12, 2),
    updated_at timestamptz,
    loaded_at timestamptz default now()
);

insert into incremental.pipeline_watermarks (pipeline_name, watermark_timestamp)
values ('orders_pipeline', '2026-05-01 00:00:00+00');

