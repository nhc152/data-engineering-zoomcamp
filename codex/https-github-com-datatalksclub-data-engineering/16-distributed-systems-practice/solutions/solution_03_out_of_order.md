# Solution 03 - Out-of-Order CDC

## Root Cause

CDC events arrived as version 1, then version 3, then version 2. A naive upsert applied version 2 last and overwrote the newer platinum tier with stale gold.

## Correct Design

Current-state table should only apply an event if its source version is newer than the existing state.

Use one of:

- source LSN
- binlog position
- source version
- source updated timestamp with careful tie-breaker

## Real System Mapping

- CDC connectors must preserve source ordering metadata.
- Kafka keying should keep same entity in same partition when order matters.
- Warehouse merge should compare version before update.

