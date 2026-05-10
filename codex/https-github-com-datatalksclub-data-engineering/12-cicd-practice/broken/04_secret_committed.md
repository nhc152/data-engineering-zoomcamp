# Broken Scenario 04 - Secret Committed

## Bad Example

Do not create a real file like this:

```text
GOOGLE_APPLICATION_CREDENTIALS_JSON={...real service account key...}
DATABASE_PASSWORD=real_password
API_TOKEN=real_token
```

## Why It Is Dangerous

Even if you delete the file in the next commit, the secret may remain in git history.

## Response

1. Revoke or rotate the credential immediately.
2. Audit access logs.
3. Remove from git history if needed.
4. Add secret scanning.
5. Replace with GitHub Secrets or cloud secret manager.

