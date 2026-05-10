# Level 03 - Deletes and Tombstones

## Goal

Handle deletes explicitly.

## Tasks

1. Inspect delete event `evt-0006`.
2. Inspect tombstone event `evt-0007`.
3. Apply change stream.
4. Query deleted records.
5. Explain why tombstone is ignored by current table but still important for broker compaction concepts.

## Expected Learning

- Delete events should update current-state with `is_deleted`.
- Changelog remains immutable.
- Tombstones are not business deletes by themselves; they are broker/log compaction mechanics.

## Questions

- When would you hard delete in target?
- When would you soft delete?
- Why can ignoring deletes make active customer/order metrics wrong?

