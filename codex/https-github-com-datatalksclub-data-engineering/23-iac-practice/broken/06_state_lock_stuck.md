# Broken Scenario 06 - State Lock Stuck

## Symptom

Terraform command fails:

```text
Error acquiring the state lock
```

## Causes

- Previous run crashed.
- Another apply is running.
- CI job did not clean up lock.

## Response

1. Confirm no apply is currently running.
2. Check CI/job history.
3. Only then consider force unlock.
4. Document the unlock.

Do not force unlock blindly.

