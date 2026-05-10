# Level 06 - Debugging Modeling Incidents

## Goal

Practice diagnosing wrong metrics caused by modeling mistakes.

## Incidents

1. SCD2 join duplicates rows.
2. Product revenue uses order-level payment.
3. Dashboards use inconsistent revenue definitions.
4. Timezone changes DAU.
5. Refunds missing from LTV.

## Tasks

For each incident:

1. Identify expected grain.
2. Identify actual grain after joins.
3. Write diagnostic query.
4. Explain root cause.
5. Apply solution.
6. Add prevention check.

## Expected Output

Create notes:

```text
notes/modeling_incident_review.md
```

Each incident should include:

- symptom
- root cause
- diagnostic SQL
- fix
- prevention

