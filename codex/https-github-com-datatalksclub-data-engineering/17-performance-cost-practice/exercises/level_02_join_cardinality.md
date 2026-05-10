# Level 02 - Join Cardinality

## Goal

Practice finding cost and metric errors caused by bad joins.

## Tasks

1. Read `sql/05_join_cardinality_bad.sql`.
2. Identify the grain of each table.
3. Explain why revenue is duplicated.
4. Read `sql/06_join_cardinality_good.sql`.
5. Write diagnostic row count queries:
   - rows before join
   - distinct order_id before join
   - rows after join
   - duplicate key check

## Expected Learning

Join bugs are both correctness issues and cost issues. Join explosion creates more rows to process and can inflate metrics.

## Interview Question

How do you debug a query where row count increases unexpectedly after a join?

