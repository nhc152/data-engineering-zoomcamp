-- Soft-delete current-state row from CDC delete event.

update cdc.orders_current
set
    is_deleted = true,
    deleted_at = now()
where order_id = 'O1003';

-- Marts can decide whether to filter deleted rows.
select *
from cdc.orders_current
where not is_deleted;

