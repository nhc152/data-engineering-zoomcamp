# Solution 02 - Drift Response

## If Manual Change Was Correct

1. Update Terraform code to match.
2. Run plan.
3. Review.
4. Apply.
5. Document why manual change happened.

## If Manual Change Was Wrong

1. Revert using Terraform.
2. Restrict manual access.
3. Add policy check if needed.
4. Document incident.

## Prevention

- Scheduled drift detection.
- Restricted production console access.
- Emergency change process.
- PR-only changes.

