create schema if not exists raw;

create table if not exists raw.orders (
    order_id text primary key,
    customer_id text not null,
    order_status text not null,
    order_amount numeric(12, 2) not null,
    order_date date not null,
    loaded_at timestamptz not null default now()
);

