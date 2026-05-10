# Broken Scenario - Source Schema Changes

## Symptom

`dbt run` fails after a source adds, removes, or changes a column type.

## Example

`raw.orders.order_status` becomes `status`.

## Why It Matters

dbt does not automatically know whether a source schema change is safe. Staging models and contracts must be reviewed.

## Diagnostic

- Check source table schema.
- Check failing compiled SQL.
- Check recent upstream changes.

## Fix

- Update source/staging deliberately.
- Add source contract expectations.
- Add alert for schema drift.

