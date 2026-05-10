# Broken Scenario 05 - No Owner Labels on Expensive Jobs

## Symptom

Monthly cost report shows expensive jobs, but nobody knows which team owns them.

## Root Cause

Jobs/resources are missing labels/tags:

- owner
- domain
- environment
- workload_type
- cost_center

## Impact

- No accountability.
- Cost alerts go nowhere.
- Hard to prioritize optimization.
- Dev experiments can look like production cost.

## Expected Fix

Define required labels and reject scheduled workloads without them.

