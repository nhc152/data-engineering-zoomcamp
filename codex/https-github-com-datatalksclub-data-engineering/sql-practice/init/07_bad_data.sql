-- Duplicate customer update: C002 appears twice. The later row should win.
insert into raw.customers (
    customer_id,
    customer_name,
    email,
    phone,
    customer_tier,
    country,
    created_at,
    updated_at,
    ingestion_timestamp
) values
('C002', ' Bob Tran  ', 'BOB+new@example.com ', '0901999999', 'platinum', 'VN', '2026-01-08 11:00:00+07', '2026-05-04 11:00:00+07', '2026-05-04 05:00:00+00'),
('C007', 'Ghost Customer', null, null, 'bronze', 'VN', '2026-05-01 00:00:00+07', '2026-05-01 00:00:00+07', '2026-05-04 05:00:00+00');

-- Duplicate order update: O1002 changed from shipped to completed.
insert into raw.orders (
    order_id,
    customer_id,
    order_status,
    order_timestamp,
    updated_at,
    source_timezone,
    ingestion_timestamp
) values
('O1002', 'C002', 'COMPLETED ', '2026-05-01 12:00:00+07', '2026-05-04 18:00:00+07', 'Asia/Ho_Chi_Minh', '2026-05-04 12:00:00+00'),

-- Missing foreign key: customer does not exist.
('O1009', 'C999', 'paid', '2026-05-04 23:50:00-05', '2026-05-05 00:10:00-05', 'America/Chicago', '2026-05-05 06:00:00+00'),

-- Late-arriving data: order date is May 1 but ingestion happens May 6.
('O1010', 'C003', 'paid', '2026-05-01 23:30:00+00', '2026-05-06 01:00:00+00', 'UTC', '2026-05-06 02:00:00+00');

-- Payment mismatch: O1009 payment does not match item total.
insert into raw.order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    updated_at,
    ingestion_timestamp
) values
('OI012', 'O1009', 'P001', 1, 120.00, '2026-05-05 00:10:00-05', '2026-05-05 06:00:00+00'),
('OI013', 'O1010', 'P002', 1, 40.00, '2026-05-06 01:00:00+00', '2026-05-06 02:00:00+00'),

-- Duplicate event-like item row from source retry.
('OI013', 'O1010', 'P002', 1, 40.00, '2026-05-06 01:00:00+00', '2026-05-06 02:05:00+00');

insert into raw.payments (
    payment_id,
    order_id,
    payment_method,
    payment_status,
    amount,
    payment_timestamp,
    updated_at,
    ingestion_timestamp
) values
('PAY009', 'O1009', 'card', 'captured', 100.00, '2026-05-05 00:00:00-05', '2026-05-05 00:10:00-05', '2026-05-05 06:00:00+00'),
('PAY010', 'O1010', 'card', 'captured', 40.00, '2026-05-01 23:35:00+00', '2026-05-06 01:00:00+00', '2026-05-06 02:00:00+00');

-- Duplicate event caused by producer retry.
insert into raw.events (
    event_id,
    customer_id,
    session_id,
    event_name,
    event_timestamp,
    payload,
    ingestion_timestamp
) values
('E006', 'C005', 'S004', 'checkout', '2026-05-03 10:29:00+09', '{"order_id": "O1005"}', '2026-05-03 02:01:00+00'),
('E007', null, 'S005', 'checkout', '2026-05-04 10:00:00+07', '{"order_id": "O9999"}', '2026-05-04 03:01:00+00');

