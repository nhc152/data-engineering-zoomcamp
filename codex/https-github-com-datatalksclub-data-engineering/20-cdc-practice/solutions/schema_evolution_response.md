# Schema Evolution Response

## Compatible Change

Adding a nullable column can be allowed if consumers tolerate unknown fields.

## Breaking Change

Renaming `order_status` to `status` is breaking because existing consumers expect `order_status`.

## Response

1. Detect schema drift.
2. Send incompatible event to DLQ.
3. Update consumer mapping deliberately.
4. Backfill current-state if needed.
5. Update data contract.

