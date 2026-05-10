# Level 07 - Interview Scenarios

Goal: practice explaining SQL decisions like a Data Engineer, not just writing queries.

## Scenario 1: Join Explosion

Prompt:

> A revenue query became 20% higher after a developer joined orders to order_items. How do you debug it?

Expected answer:

- Check grain of both tables.
- Count rows and distinct order IDs before and after join.
- Check whether payment/order-level amounts are repeated per item.
- Aggregate item-level data before joining.
- Add duplicate/reconciliation checks.

## Scenario 2: Deduplication

Prompt:

> Source sends multiple versions of the same order. How do you keep the correct one?

Expected answer:

- Identify business key: `order_id`.
- Choose winning rule: latest `updated_at`, tie-break with `ingestion_timestamp`.
- Use `row_number()`.
- Ensure rule is deterministic.
- Test duplicate keys after staging.

## Scenario 3: Incremental Failure

Prompt:

> An incremental job uses `where order_date > max(order_date)`. What can go wrong?

Expected answer:

- Late-arriving data can be missed.
- Updates to old orders can be missed.
- Reprocessing by order date alone is not enough.
- Prefer `updated_at` watermark with lookback and merge/upsert.

## Scenario 4: Data Quality

Prompt:

> Pipeline succeeded but dashboard is wrong. What do you check?

Expected answer:

- Source freshness.
- Row count by date.
- Duplicate business keys.
- Referential integrity.
- Metric reconciliation.
- Recent schema/status changes.
- Business filters such as cancelled/refunded orders.

## Scenario 5: Modeling

Prompt:

> Why not build all reporting from raw tables directly?

Expected answer:

- Raw data is dirty and unstable.
- Staging standardizes names, types, statuses.
- Facts/dimensions define stable grain.
- Marts provide business-ready tables.
- Quality checks are easier at defined layer boundaries.

## Practice Format

For each scenario, answer in this structure:

1. Clarify the expected metric or grain.
2. State likely causes.
3. Write diagnostic SQL.
4. Propose fix.
5. Propose prevention check.

