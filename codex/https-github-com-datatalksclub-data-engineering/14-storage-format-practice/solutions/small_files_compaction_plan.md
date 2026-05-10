# Solution - Small Files Compaction Plan

## Detection

Track:

- number of files per partition
- average file size
- query planning time
- object storage list operations

## Compaction Policy

Example:

```text
For daily event partitions:
- compact every 1 hour for hot data
- compact again at end of day
- target file size: 128MB-512MB depending on engine
- keep raw files unchanged
```

## Trade-off

Compaction costs compute, but it reduces repeated query overhead.

