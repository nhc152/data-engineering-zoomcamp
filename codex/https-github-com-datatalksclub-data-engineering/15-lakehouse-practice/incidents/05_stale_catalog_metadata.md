# Incident 05 - Stale Catalog Metadata

## Symptom

Spark could read a table but Trino returned stale results. Catalog metadata was not refreshed consistently.

## Root Cause

Multiple engines used table metadata differently, and catalog refresh/compatibility was not validated.

## Impact

- Analysts saw stale data.
- Trust in gold table dropped.
- Debugging took hours because object files looked correct.

## Prevention

- Standardize catalog access.
- Test multi-engine read paths.
- Monitor snapshot IDs across engines.
- Avoid direct path reads.
- Document engine compatibility.

