# Level 03 - Window Functions

Goal: use window functions for deduplication, ranking, and time-based analytics.

## Tasks

1. Find duplicate raw orders by `order_id`.
2. Use `row_number()` to keep the latest order version.
3. Find duplicate customers and keep the latest customer profile.
4. Rank each customer's orders by timestamp.
5. Calculate the previous order timestamp for each customer.
6. Build daily revenue and calculate running revenue.
7. Calculate a 3-day moving average revenue.

## Dedup Pattern

```sql
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc, ingestion_timestamp desc
        ) as rn
    from raw.orders
)

select *
from ranked
where rn = 1;
```

## Questions to Answer

- Why is `updated_at desc` not always enough?
- Why do we add `ingestion_timestamp desc`?
- What happens if two rows tie on all ordering fields?

## Done When

You can deduplicate a table and explain the business rule used to choose the winning record.

