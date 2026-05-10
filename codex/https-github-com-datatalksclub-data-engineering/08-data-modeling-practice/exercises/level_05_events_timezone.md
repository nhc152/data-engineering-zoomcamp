# Level 05 - Event Modeling and Timezone

## Goal

Understand how event timestamps and reporting timezone affect DAU.

## Tasks

1. Inspect `fct_events` in `sql/03_facts.sql`.
2. Inspect `mart_daily_active_users_vn` in `sql/04_marts.sql`.
3. Open `broken/04_timezone_changes_dau.sql`.
4. Explain why UTC DAU and VN DAU can differ.
5. Read `solutions/04_fix_timezone_dau.md`.

## Expected Output

You should be able to say:

```text
Event timestamps should be stored in UTC, but reporting dates must be derived intentionally for the business timezone.
```

## Questions

- Should global dashboards use UTC or local date?
- What happens to DAU near midnight?
- Why should BI users not cast timestamp to date themselves?

