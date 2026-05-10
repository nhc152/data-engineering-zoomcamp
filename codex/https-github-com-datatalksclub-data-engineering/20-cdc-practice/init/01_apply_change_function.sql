create or replace function cdc.apply_order_change(
    p_event_id text,
    p_source_lsn bigint,
    p_source_ts_ms bigint,
    p_op text,
    p_primary_key text,
    p_after_data jsonb,
    p_before_data jsonb
) returns void
language plpgsql
as $$
declare
    v_order_id text;
    v_customer_id text;
    v_order_status text;
    v_order_amount numeric(12, 2);
    v_updated_at timestamptz;
begin
    if p_op = 'd' then
        v_order_id := coalesce(p_primary_key, p_before_data ->> 'order_id');

        insert into cdc.orders_current (
            order_id,
            is_deleted,
            deleted_at,
            last_event_id,
            last_source_lsn,
            last_source_ts_ms
        )
        values (
            v_order_id,
            true,
            to_timestamp(p_source_ts_ms / 1000.0),
            p_event_id,
            p_source_lsn,
            p_source_ts_ms
        )
        on conflict (order_id) do update set
            is_deleted = true,
            deleted_at = to_timestamp(p_source_ts_ms / 1000.0),
            last_event_id = excluded.last_event_id,
            last_source_lsn = excluded.last_source_lsn,
            last_source_ts_ms = excluded.last_source_ts_ms,
            applied_at = now()
        where cdc.orders_current.last_source_lsn < excluded.last_source_lsn;

        return;
    end if;

    if p_after_data is null then
        return;
    end if;

    v_order_id := p_after_data ->> 'order_id';
    v_customer_id := p_after_data ->> 'customer_id';
    v_order_status := p_after_data ->> 'order_status';
    v_order_amount := nullif(p_after_data ->> 'order_amount', '')::numeric;
    v_updated_at := nullif(p_after_data ->> 'updated_at', '')::timestamptz;

    insert into cdc.orders_current (
        order_id,
        customer_id,
        order_status,
        order_amount,
        updated_at,
        is_deleted,
        deleted_at,
        last_event_id,
        last_source_lsn,
        last_source_ts_ms
    )
    values (
        v_order_id,
        v_customer_id,
        v_order_status,
        v_order_amount,
        v_updated_at,
        false,
        null,
        p_event_id,
        p_source_lsn,
        p_source_ts_ms
    )
    on conflict (order_id) do update set
        customer_id = excluded.customer_id,
        order_status = excluded.order_status,
        order_amount = excluded.order_amount,
        updated_at = excluded.updated_at,
        is_deleted = false,
        deleted_at = null,
        last_event_id = excluded.last_event_id,
        last_source_lsn = excluded.last_source_lsn,
        last_source_ts_ms = excluded.last_source_ts_ms,
        applied_at = now()
    where cdc.orders_current.last_source_lsn < excluded.last_source_lsn;
end;
$$;

