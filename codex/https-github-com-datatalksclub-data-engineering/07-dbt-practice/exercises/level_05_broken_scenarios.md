# Level 05 - Broken Scenarios

## Goal

Debug realistic dbt production failures.

## Scenarios

1. `broken/hardcoded_table_breaks_lineage.sql`
2. `broken/incremental_misses_late_update.sql`
3. `broken/uniqueness_test_fails.md`
4. `broken/accepted_values_test_fails.md`
5. `broken/nested_views_slow.md`
6. `broken/source_schema_changes.md`

## Tasks

For each scenario:

1. Describe the symptom.
2. Identify the root cause.
3. Explain how dbt helps or fails to help.
4. Propose fix.
5. Propose prevention.

## Expected Output

Write notes in:

```text
notes/dbt_failure_review.md
```

