# Exercise 04 - OLTP Replication

## Scenario

The analytics team needs near-real-time copies of `orders`, `customers`, and `payments` from an OLTP database. They need current-state tables in the warehouse. Deletes must be reflected.

## Requirements

- Latency: seconds/minutes.
- Source: mutable OLTP tables.
- Deletes: required.
- Schema drift: possible.
- Replay/recovery: required.

## Tasks

1. Choose pattern.
2. Design changelog table.
3. Design current-state table.
4. Define delete handling.
5. Define schema evolution policy.
6. Define resnapshot plan.
7. Explain why API polling may be weaker.

## Expected Direction

Likely pattern:

```text
CDC to warehouse
```

## Deliverable

Write:

```text
oltp_replication_design.md
```

