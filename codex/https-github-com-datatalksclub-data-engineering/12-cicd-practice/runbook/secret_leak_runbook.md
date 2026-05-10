# Secret Leak Runbook

## Immediate Actions

1. Revoke/rotate leaked credential.
2. Disable affected service account if necessary.
3. Audit access logs.
4. Notify owner/security contact.
5. Remove secret from repo history if required.

## Follow-Up

- Add secret scanning.
- Move secret to GitHub Secrets or secret manager.
- Replace long-lived keys with short-lived/OIDC where possible.
- Review IAM permissions.
- Document incident.

