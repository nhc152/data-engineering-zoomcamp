# Exercise 05 - Customer 360 Fan-in

## Scenario

The company wants a Customer 360 table combining CRM customers, app users, support contacts, and marketing leads. Each source has different IDs and data quality.

## Requirements

- Multiple sources.
- Identity resolution.
- Source precedence rules.
- Duplicate customer risk.
- PII governance.
- Refresh daily or hourly.

## Tasks

1. Choose pattern.
2. Define canonical customer model.
3. Define matching rules.
4. Define source priority.
5. Define quality checks.
6. Define human review/quarantine for uncertain matches.
7. Explain why this is not just a join.

## Expected Direction

Likely pattern:

```text
Fan-in with canonical model
```

Often implemented with:

```text
Batch ELT or micro-batch
```

## Deliverable

Write:

```text
customer_360_design.md
```

