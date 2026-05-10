# Solution - Retention Policy Fix

## Separate Data Classes

| Data Type | Retention |
|---|---|
| temp/scratch | 7-30 days |
| raw Restricted | 90 days unless compliance requires more/less |
| curated marts | business-defined |
| audit logs | 1-7 years depending policy |

## Rule

Never apply temp-data retention rules to audit logs.

## Review Gate

Retention changes for audit, raw Restricted, or finance data require:

- data owner approval
- security/privacy review
- rollback/recovery impact review

