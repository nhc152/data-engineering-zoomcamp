# Solution - Responding to dbt Test Failures

## Rule

A dbt test failure is not automatically a model bug. It can be:

- source data bug
- model bug
- test definition bug
- business rule change

## Response Workflow

1. Query failing rows.
2. Identify affected model and downstream marts.
3. Decide whether to block publish.
4. Fix source/model/test.
5. Add prevention if missing.

## Example: Missing Customer Relationship

This lab includes order `O1007` with customer `C999`.

Options:

- Block mart publish until source fixes customer.
- Route order to unknown customer dimension.
- Allow but report referential integrity warning.

Production choice depends on business policy.

