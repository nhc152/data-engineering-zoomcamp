# Incident 04 - Schema Evolution Allows Bad Column

## Symptom

A new column `revenue` arrived as string in silver orders. Gold revenue mart started failing casts.

## Root Cause

Schema auto-merge allowed a source change without review.

## Impact

- Gold mart failed.
- BI dashboard missed SLA.
- Data contract was unclear.

## Prevention

- Bronze can be permissive.
- Silver should validate important schema.
- Gold changes require review.
- Alert on type changes.
- Track schema version.

