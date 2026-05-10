drop schema if exists raw cascade;
create schema raw;

create table raw.customers (
    customer_id text,
    customer_name text,
    email text,
    country text,
    customer_tier text,
    created_at timestamp,
    updated_at timestamp,
    loaded_at timestamp
);

create table raw.products (
    product_id text,
    product_name text,
    category text,
    unit_price numeric(12, 2),
    is_active boolean,
    updated_at timestamp,
    loaded_at timestamp
);

create table raw.orders (
    order_id text,
    customer_id text,
    order_status text,
    order_timestamp timestamp,
    updated_at timestamp,
    loaded_at timestamp
);

create table raw.order_items (
    order_item_id text,
    order_id text,
    product_id text,
    quantity integer,
    unit_price numeric(12, 2),
    loaded_at timestamp
);

create table raw.payments (
    payment_id text,
    order_id text,
    payment_status text,
    amount numeric(12, 2),
    payment_timestamp timestamp,
    updated_at timestamp,
    loaded_at timestamp
);

insert into raw.customers values
('C001', ' Alice Nguyen ', 'ALICE@example.com ', 'VN', 'silver', '2026-01-05 09:00:00', '2026-05-01 01:00:00', '2026-05-01 02:00:00'),
('C002', 'Bob Tran', 'bob@example.com', 'VN', 'gold', '2026-01-08 11:00:00', '2026-05-01 01:00:00', '2026-05-01 02:00:00'),
('C002', ' Bob Tran ', 'bob+new@example.com', 'VN', 'platinum', '2026-01-08 11:00:00', '2026-05-04 11:00:00', '2026-05-04 12:00:00'),
('C003', 'Carla Smith', 'carla@example.com', 'US', 'bronze', '2026-01-15 13:00:00', '2026-05-01 01:00:00', '2026-05-01 02:00:00'),
('C004', 'Duy Le', 'duy@example.com', 'VN', 'silver', '2026-02-02 10:30:00', '2026-05-01 01:00:00', '2026-05-01 02:00:00'),
('C005', 'Emily Park', 'emily@example.com', 'KR', 'gold', '2026-02-10 08:00:00', '2026-05-01 01:00:00', '2026-05-01 02:00:00'),
('C999', 'Unknown Customer', null, 'UNKNOWN', 'bronze', '2026-05-04 00:00:00', '2026-05-04 00:00:00', '2026-05-04 03:00:00');

insert into raw.products values
('P001', 'Mechanical Keyboard', 'electronics', 120.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00'),
('P002', 'Wireless Mouse', 'electronics', 40.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00'),
('P003', 'USB-C Hub', 'electronics', 75.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00'),
('P004', 'Notebook', 'office', 8.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00'),
('P005', 'Desk Lamp', 'home', 55.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00'),
('P006', 'Standing Desk', 'home', 350.00, true, '2026-05-01 00:00:00', '2026-05-01 02:00:00');

insert into raw.orders values
('O1001', 'C001', 'PAID', '2026-05-01 01:15:00', '2026-05-01 01:20:00', '2026-05-01 02:00:00'),
('O1002', 'C002', 'Shipped', '2026-05-01 05:00:00', '2026-05-01 05:10:00', '2026-05-01 06:00:00'),
('O1002', 'C002', 'COMPLETED ', '2026-05-01 05:00:00', '2026-05-04 12:00:00', '2026-05-04 13:00:00'),
('O1003', 'C003', 'completed', '2026-05-02 09:00:00', '2026-05-02 09:15:00', '2026-05-02 10:00:00'),
('O1004', 'C004', 'cancelled', '2026-05-02 07:00:00', '2026-05-02 08:00:00', '2026-05-02 09:00:00'),
('O1005', 'C005', 'paid', '2026-05-03 01:30:00', '2026-05-03 01:40:00', '2026-05-03 02:00:00'),
('O1006', 'C001', 'refunded', '2026-05-03 16:00:00', '2026-05-04 10:00:00', '2026-05-04 11:00:00'),
('O1007', 'C999', 'paid', '2026-05-04 02:20:00', '2026-05-04 02:25:00', '2026-05-04 03:00:00');

insert into raw.order_items values
('OI001', 'O1001', 'P001', 1, 120.00, '2026-05-01 02:00:00'),
('OI002', 'O1001', 'P002', 2, 40.00, '2026-05-01 02:00:00'),
('OI003', 'O1002', 'P003', 1, 75.00, '2026-05-01 06:00:00'),
('OI004', 'O1003', 'P004', 5, 8.00, '2026-05-02 10:00:00'),
('OI005', 'O1003', 'P005', 1, 55.00, '2026-05-02 10:00:00'),
('OI006', 'O1004', 'P006', 1, 350.00, '2026-05-02 09:00:00'),
('OI007', 'O1005', 'P001', 1, 120.00, '2026-05-03 02:00:00'),
('OI008', 'O1005', 'P004', 3, 8.00, '2026-05-03 02:00:00'),
('OI009', 'O1006', 'P002', 1, 40.00, '2026-05-04 11:00:00'),
('OI010', 'O1007', 'P003', 1, 75.00, '2026-05-04 03:00:00');

insert into raw.payments values
('PAY001', 'O1001', 'captured', 200.00, '2026-05-01 01:16:00', '2026-05-01 01:20:00', '2026-05-01 02:00:00'),
('PAY002', 'O1002', 'captured', 75.00, '2026-05-01 05:03:00', '2026-05-04 12:00:00', '2026-05-04 13:00:00'),
('PAY003', 'O1003', 'captured', 95.00, '2026-05-02 09:05:00', '2026-05-02 09:15:00', '2026-05-02 10:00:00'),
('PAY004', 'O1004', 'voided', 0.00, '2026-05-02 07:05:00', '2026-05-02 08:00:00', '2026-05-02 09:00:00'),
('PAY005', 'O1005', 'captured', 144.00, '2026-05-03 01:32:00', '2026-05-03 01:40:00', '2026-05-03 02:00:00'),
('PAY006', 'O1006', 'refunded', -40.00, '2026-05-04 10:05:00', '2026-05-04 10:10:00', '2026-05-04 11:00:00'),
('PAY007', 'O1007', 'captured', 75.00, '2026-05-04 02:21:00', '2026-05-04 02:25:00', '2026-05-04 03:00:00');
