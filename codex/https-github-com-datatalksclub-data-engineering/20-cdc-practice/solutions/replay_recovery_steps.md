# Replay Recovery Steps

## When to Replay

- Current-state table corrupted.
- Apply logic changed.
- Downstream mart was built from bad state.
- Need to recover after partial sink failure.

## Steps

1. Stop downstream publish.
2. Identify affected table/key range/time range.
3. Verify raw changelog retention covers the period.
4. Backup current-state table if needed.
5. Truncate or isolate affected state.
6. Replay changelog in source order.
7. Validate counts/checksums.
8. Rebuild downstream marts.
9. Resume publish.

## Key Rule

Replay only works if raw changelog exists and is complete.

