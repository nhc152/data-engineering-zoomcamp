-- Core protection against older updates overwriting newer state.

-- In upsert/update logic:
-- apply incoming event only when incoming source_lsn is newer.

where cdc.orders_current.last_source_lsn < excluded.last_source_lsn;

