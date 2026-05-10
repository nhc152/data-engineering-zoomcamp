# Broken Scenario 05 - Test Data Too Different From Production

## Symptom

CI passes, but production fails after deployment.

## Root Cause

Test data is too clean and too small. It does not include:

- duplicate keys
- unknown status values
- nulls
- late-arriving records
- refunds/cancellations
- schema drift

## Prevention

- Add representative edge cases to seeds/fixtures.
- Add data tests for important assumptions.
- Maintain small but realistic golden dataset.
- Add staging validation before production publish.

