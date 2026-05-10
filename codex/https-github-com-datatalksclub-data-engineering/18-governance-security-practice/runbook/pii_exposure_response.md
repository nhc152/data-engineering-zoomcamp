# Runbook - PII Exposure Response

## Trigger

PII is exposed through bucket, table, dashboard, export, or access grant.

## Immediate Actions

1. Contain exposure:
   - remove public access
   - restrict dashboard/table
   - revoke excessive IAM
2. Preserve audit logs.
3. Identify data classification and impacted columns.
4. Identify exposure window.
5. Identify who accessed/exported data.
6. Notify security/privacy/legal owner.
7. Start incident report.

## Investigation Questions

- What data was exposed?
- Was it raw, staging, or mart?
- Was data exported?
- Who had access?
- Was access intentional or accidental?
- Did service account credentials leak?

## Remediation

- Mask or remove PII.
- Replace raw source with curated mart.
- Update IAM.
- Add policy guardrail.
- Add alert.
- Review similar dashboards/datasets.

