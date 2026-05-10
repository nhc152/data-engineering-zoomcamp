# Solution 05 - Owner Label Policy

## Required Labels

- `owner`
- `domain`
- `environment`
- `workload_type`
- `criticality`
- `cost_center`

## Enforcement

Options:

- CI check for config files.
- Terraform policy.
- Deployment checklist.
- Scheduled audit query.

## Trade-off

Label enforcement adds process overhead, but it makes cost actionable.

## Prevention

No scheduled production workload should run without an owner and cost center.

