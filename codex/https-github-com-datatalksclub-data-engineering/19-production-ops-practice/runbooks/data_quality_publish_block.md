# Runbook - Data Quality Blocks Publish

## Symptom

Pipeline built output but publish gate blocked it.

## Immediate Response

1. Identify failing check.
2. Confirm severity: warn or block.
3. Inspect sample rows.
4. Compare with previous successful partition.
5. Notify business owner if SLA risk exists.

## Decision Tree

### Duplicate primary key

Action:

- Block publish.
- Investigate source duplicates or incremental append.
- Rebuild partition with dedup/merge logic.

### Freshness failure

Action:

- Block publish if data is incomplete.
- Contact source owner.
- Keep previous published data.

### Reconciliation failure

Action:

- Block publish.
- Compare source payment totals vs mart totals.
- Check cancelled/refunded logic.
- Check join explosion.

### Accepted value warning

Action:

- If new status is non-critical, publish with warning and open follow-up.
- If metric logic depends on status, block publish.

## Manual Override

Only allowed with:

- business owner approval
- documented impact
- expiry time
- follow-up ticket

