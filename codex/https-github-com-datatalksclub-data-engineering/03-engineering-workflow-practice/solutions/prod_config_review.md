# Review - Accidental Prod Config Change

## Risk

The broken config points to production and uses:

```text
write_mode: overwrite
backfill_start_date: 2024-01-01
quality.fail_on_error: false
```

This could overwrite production marts for a large historical range while ignoring quality failures.

## Required Fix

- Do not run this config from a feature branch.
- Use dev/staging environment first.
- Require explicit approval for production backfill.
- Set `quality.fail_on_error: true`.
- Add row count and reconciliation checks.
- Include rollback plan.

