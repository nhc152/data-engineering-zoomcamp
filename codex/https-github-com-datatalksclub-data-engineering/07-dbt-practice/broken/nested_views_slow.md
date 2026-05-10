# Broken Scenario - Nested Views Become Slow

## Symptom

Dashboard query is slow and expensive.

## Cause

The dashboard queries a mart that is a view on top of many views. Every dashboard refresh recomputes the full chain.

## Diagnostic

1. Run `dbt compile`.
2. Inspect compiled SQL in `target/compiled`.
3. Check warehouse query plan.
4. Identify repeated expensive joins/aggregations.

## Fix

- Materialize heavy marts as tables.
- Materialize heavy intermediate models if reused.
- Create aggregate marts for dashboard queries.

