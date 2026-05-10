# Broken Scenario 03 - Spark Job Rerun Doubles Compute

## Symptom

Spark job fails near the end. Rerun recomputes all upstream stages and doubles compute cost.

## Root Cause

The job writes only final output and has no checkpoint/intermediate persistence strategy. Repeated actions also recompute lineage.

## Evidence To Collect

- Spark UI job/stage history
- failed stage
- shuffle size
- output write status
- whether intermediate results are reused
- whether job is idempotent

## Expected Fix

Options:

- checkpoint/persist expensive reusable intermediate results
- write validated intermediate tables
- split job into idempotent stages
- avoid unnecessary repeated actions like `count()` then `write()` without cache

## Trade-off

Checkpoint/intermediate writes add storage and pipeline complexity, but reduce rerun cost.

