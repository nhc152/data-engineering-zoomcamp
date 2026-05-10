# Solution 03 - Spark Rerun Strategy

## Fix Options

1. Split job into idempotent stages.
2. Persist/checkpoint expensive reused intermediate data.
3. Write temporary output and validate before publish.
4. Avoid repeated actions that recompute the same lineage.
5. Use partition-level reruns when possible.

## Trade-off

More checkpoints/intermediate tables:

- reduce rerun cost
- improve recovery
- increase storage
- add operational complexity

## Prevention

- Track runtime by stage.
- Alert on repeated reruns.
- Add output validation before publish.
- Record run metadata.

