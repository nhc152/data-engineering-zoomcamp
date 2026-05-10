# Level 03 - Marts and Tests

## Goal

Build tested facts, dimensions, and marts.

## Tasks

1. Run `dbt build --select marts`.
2. Inspect `models/marts/_marts__models.yml`.
3. Run `dbt test --select marts`.
4. Run singular tests in `tests/`.
5. Explain any test failures.

## Expected Learning

- Generic tests enforce keys and accepted values.
- Relationship tests catch missing foreign keys.
- Singular tests capture business rules.

## Optional Failure Drill

After the first successful build, temporarily delete or comment out customer `C999` from the raw seed and reset the database. The relationship test from `fct_orders.customer_id` to `dim_customers.customer_id` should fail.

## Questions

- Is this a source quality issue or model issue?
- Would you block deployment?
- Would you quarantine the record or allow unknown customer?
