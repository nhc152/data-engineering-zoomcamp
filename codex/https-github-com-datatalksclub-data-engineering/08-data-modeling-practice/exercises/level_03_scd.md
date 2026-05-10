# Level 03 - SCD Type 1 and Type 2

## Goal

Understand how slowly changing dimensions affect historical reporting.

## Tasks

1. Read the SCD section in `docs/data_model.md`.
2. Open `broken/01_scd2_join_duplicates.sql`.
3. Explain why the bad join duplicates orders.
4. Open `solutions/01_fix_scd2_join.sql`.
5. Explain why the fixed join preserves one row per order.

## Expected Output

You should be able to say:

```text
SCD2 has one row per customer version, not one row per customer.
To join a fact to SCD2, use business key plus the fact timestamp within valid_from/valid_to.
```

## Questions

- When is SCD1 enough?
- When is SCD2 required?
- What happens if valid date ranges overlap?

