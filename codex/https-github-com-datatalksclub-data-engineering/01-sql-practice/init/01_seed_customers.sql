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
('C001', '  Alice Nguyen ', 'ALICE@example.com ', '0901000001', 'silver', 'VN', '2026-01-05 09:00:00+07', '2026-04-01 10:00:00+07', '2026-05-01 01:00:00+00'),
('C002', 'Bob Tran', 'bob@example.com', '0901000002', 'gold', 'VN', '2026-01-08 11:00:00+07', '2026-04-12 08:00:00+07', '2026-05-01 01:00:00+00'),
('C003', 'Carla Smith', 'carla@example.com', null, 'bronze', 'US', '2026-01-15 13:00:00+00', '2026-03-20 09:00:00+00', '2026-05-01 01:00:00+00'),
('C004', 'Duy Le', 'duy@example.com', '0901000004', 'silver', 'VN', '2026-02-02 10:30:00+07', '2026-04-18 14:00:00+07', '2026-05-01 01:00:00+00'),
('C005', 'Emily Park', 'emily@example.com', '0901000005', 'gold', 'KR', '2026-02-10 08:00:00+09', '2026-04-22 09:00:00+09', '2026-05-01 01:00:00+00'),
('C006', 'Frank Miller', 'frank@example.com', '0901000006', 'bronze', 'US', '2026-03-01 08:00:00+00', '2026-04-25 08:00:00+00', '2026-05-01 01:00:00+00');

