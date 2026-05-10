# Solution 04 - Secret Leak Response

If a secret is committed:

1. Assume it is compromised.
2. Revoke or rotate it immediately.
3. Audit usage logs.
4. Remove from git history if required.
5. Add secret scanning to CI.
6. Replace with GitHub Secrets, OIDC, or secret manager.

Do not:

- only delete the file in a new commit
- keep using the same token
- paste secrets into issue comments or logs

