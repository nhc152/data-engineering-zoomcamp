# Level 03 - Production Policies

## Goal

Write production policies for lakehouse tables.

## Tasks

1. Write compaction policy for streaming bronze events.
2. Write vacuum/retention policy for finance gold tables.
3. Write schema evolution policy for silver orders.
4. Write catalog ownership policy.
5. Define who can write to gold tables.

## Expected Output

Create:

```text
notes/lakehouse_policies.md
```

Include:

- compaction thresholds
- retention window
- rollback requirement
- schema change approval
- table owner
- allowed writers/readers

