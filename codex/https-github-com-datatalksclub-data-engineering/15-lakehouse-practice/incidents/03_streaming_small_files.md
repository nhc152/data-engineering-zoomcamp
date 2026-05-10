# Incident 03 - Streaming Creates Small Files

## Symptom

Queries against bronze events became slow. Table had hundreds of thousands of small files.

## Root Cause

Streaming micro-batches wrote tiny files continuously. No compaction policy existed.

## Impact

- Query planning became slow.
- Metadata operations became expensive.
- Downstream silver jobs slowed down.

## Prevention

- Tune streaming trigger interval.
- Compact regularly.
- Monitor average file size.
- Avoid over-partitioning.
- Batch low-volume streams when possible.

