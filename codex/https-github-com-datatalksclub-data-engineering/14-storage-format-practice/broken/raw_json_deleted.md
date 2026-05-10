# Broken Scenario - Raw JSON Deleted Before Reprocessing

## Symptom

A bug is found in curated Parquet logic, but raw JSON files were deleted. The team cannot rebuild accurate historical data.

## Root Cause

Raw retention policy was treated as storage cleanup only, not as a recovery feature.

## Impact

- Cannot replay original source payload.
- Cannot fix parser bugs accurately.
- Must rely on already-transformed data, which may contain the bug.

## Prevention

- Define raw retention based on recovery requirements.
- Archive raw data if hot storage is too expensive.
- Do not overwrite raw files.
- Track source file manifest.

