-- Broken example.
-- This kind of logic lets older CDC events overwrite newer state.
-- Do not run in production.

update cdc.orders_current
set
    order_status = 'paid',
    last_source_lsn = 100
where order_id = 'O1002';

