# Solution 01 - Prevent Destroying Production Bucket

## Immediate Action

Do not apply the plan.

## Investigation

Check:

- Was the resource renamed?
- Was state lost?
- Was module path changed?
- Was bucket name changed?
- Does the change require `moved` block?
- Does the resource need `terraform import`?

## Prevention

- Use `prevent_destroy` for critical buckets.
- Use remote state.
- Use plan review.
- Use `moved` blocks for refactors.
- Require approval for destructive changes.

## Interview Language

I would block the apply. Raw production buckets are recovery assets. If Terraform wants to destroy or replace one, I treat it as a potential data-loss incident until proven safe.

