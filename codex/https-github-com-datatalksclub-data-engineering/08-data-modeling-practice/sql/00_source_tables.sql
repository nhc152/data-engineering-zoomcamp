-- PostgreSQL-style source table definitions for modeling practice.
-- These are reference DDLs. They are designed to make grain explicit.

create table raw_customers (
    customer_id text,
    customer_name text,
    email text,
    country text,
    customer_tier text,
    updated_at timestamp
);

create table raw_customer_tier_history (
    customer_id text,
    customer_tier text,
    valid_from timestamp,
    valid_to timestamp
);

create table raw_products (
    product_id text,
    product_name text,
    category text,
    current_unit_price numeric(12, 2),
    updated_at timestamp
);

create table raw_orders (
    order_id text,
    customer_id text,
    order_status text,
    order_timestamp timestamp,
    updated_at timestamp
);

create table raw_order_items (
    order_item_id text,
    order_id text,
    product_id text,
    quantity integer,
    unit_price numeric(12, 2)
);

create table raw_payments (
    payment_id text,
    order_id text,
    payment_status text,
    amount numeric(12, 2),
    payment_timestamp timestamp
);

create table raw_refunds (
    refund_id text,
    order_id text,
    payment_id text,
    refund_amount numeric(12, 2),
    refund_timestamp timestamp
);

create table raw_events (
    event_id text,
    customer_id text,
    session_id text,
    event_name text,
    event_timestamp_utc timestamp
);

