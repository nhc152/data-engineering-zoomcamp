# Level 06 - Debugging

Goal: practice debugging production-style SQL incidents.

## Incident 1: Revenue Is Too High

Symptoms:

- Daily revenue dashboard is higher than payment reports.
- The query joins orders, order_items, and payments.

Tasks:

1. Run `interview/broken_join.sql`.
2. Count rows before and after the join.
3. Identify the grain after each join.
4. Fix the query using `marts.fct_orders`.
5. Add a quality check that would catch this issue.

## Incident 2: Missing Customer

Symptoms:

- Some orders have no customer attributes.

Tasks:

1. Run `quality/referential_integrity_checks.sql`.
2. Find the missing customer key.
3. Decide whether to reject, quarantine, or allow the record.
4. Write the business assumption in README style.

## Incident 3: Payment Mismatch

Symptoms:

- Finance says order item totals and captured payments do not match.

Tasks:

1. Run `interview/metric_mismatch.sql`.
2. Identify mismatched orders.
3. Explain whether each mismatch is valid business behavior or data quality issue.
4. Suggest a data quality threshold.

## Incident 4: Duplicate Append

Symptoms:

- Incremental table grows every time the job reruns.

Tasks:

1. Run `incremental/append_load.sql` twice.
2. Find duplicates in `incremental.fct_orders_append`.
3. Fix with upsert.
4. Explain idempotency.

## Done When

You can debug with row counts, distinct keys, grain checks, and reconciliation queries instead of guessing.

