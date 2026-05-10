# Level 01 - Medallion Design

## Goal

Design bronze, silver, and gold layers for ecommerce.

## Tasks

1. Define bronze tables for orders, payments, customers, and events.
2. Define silver tables for cleaned current-state entities.
3. Define gold tables for facts, dimensions, and marts.
4. Write grain for each table.
5. Write owner and SLA for each gold table.

## Expected Output

Create a design note:

```text
notes/medallion_design.md
```

Include:

- table name
- layer
- grain
- source
- owner
- SLA
- quality checks

## Questions

- What data must be preserved in bronze?
- What logic belongs in silver?
- What logic belongs in gold?
- Which tables need rollback/time travel most?

