# Policy - Required Labels

Every resource should include labels:

```text
env
owner
cost_center
managed_by
system
```

## Why

Labels enable:

- cost attribution
- ownership
- incident routing
- cleanup
- governance reports

## Reject If

- Resource has no owner.
- Resource has no environment.
- Resource has no cost center.

