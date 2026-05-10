# Solution: Retry Duplicate Load

Correct behavior:

- Add a unique constraint on the business key.
- Use upsert instead of blind append.
- Make retry safe before enabling retry.

Implemented in:

```text
sql/00_schema.sql
src/load.py::upsert_orders
```

Key SQL:

```sql
on conflict (order_id) do update set
    customer_id = excluded.customer_id,
    amount = excluded.amount,
    updated_at = excluded.updated_at
where orders.updated_at <= excluded.updated_at
```

Verification:

Run the same command twice with the same `--run-id`. Row count should not double.

