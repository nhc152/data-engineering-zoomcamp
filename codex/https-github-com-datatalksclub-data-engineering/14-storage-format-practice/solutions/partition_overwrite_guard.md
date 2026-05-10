# Solution - Partition Overwrite Guard

Before writing curated output, validate the target path.

Bad:

```text
data/lake/orders/
```

Good:

```text
data/lake/orders/order_date=2026-05-01/
```

Recommended guardrails:

- Require `order_date` parameter.
- Reject empty partition value.
- Reject root table output path for partition overwrite mode.
- Write to temp path first.
- Count rows before publish.
- Keep raw immutable for rebuild.

