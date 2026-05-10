# Model Answer - Customer 360 Fan-in

## Recommended Pattern

Fan-in with canonical customer model, usually implemented by Batch ELT or micro-batch.

## Why

Customer 360 combines multiple sources with different semantics. The hard part is identity resolution and source precedence, not raw ingestion speed.

## Architecture

```text
CRM customers
app users
support contacts
marketing leads
  -> staging per source
  -> identity resolution
  -> canonical customer dimension
  -> customer 360 mart
```

## Required Controls

- Source priority rules.
- Matching confidence score.
- Quarantine for ambiguous matches.
- PII access controls.
- Audit trail for merges.

## Failure Modes

- Two people merged incorrectly.
- One person split into multiple profiles.
- Source priority not documented.
- PII leaked to wide audience.

## Trade-off Language

This is not just a join. Fan-in requires semantic alignment, identity resolution, governance, and quality checks.

