# Level 04 - Environment and Secrets

## Goal

Practice identifying unsafe credential and environment patterns.

## Tasks

1. Inspect `.env.example`.
2. Inspect `broken/01_ci_uses_prod_credentials.yml`.
3. Inspect `broken/04_secret_committed.md`.
4. Write a safe environment separation policy.
5. Write a secret rotation response for leaked credentials.

## Expected Output

Create notes:

```text
notes/env_and_secrets_policy.md
```

Include:

- dev/staging/prod separation
- GitHub Secrets usage
- no real secret in git
- rotation procedure

## Interview Question

Why is deleting a leaked secret from the latest commit not enough?

