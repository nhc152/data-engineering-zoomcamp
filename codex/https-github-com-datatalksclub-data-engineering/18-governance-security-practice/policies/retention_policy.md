# Retention Policy

## Purpose

Balance analytics, recovery, compliance, and privacy.

## Retention Matrix

| Data Zone | Example | Retention | Reason |
|---|---|---|---|
| Raw restricted | raw customer exports with PII | 90 days by default | reprocessing with privacy limit |
| Raw non-PII | clickstream events without direct PII | 180-365 days | replay and historical analysis |
| Staging | typed cleaned tables | 30-90 days | rebuildable from raw |
| Curated marts | finance/customer/product marts | business-defined, often 2-7 years | reporting history |
| Audit logs | access and admin logs | 1-7 years depending policy | security investigation |
| Temp/scratch | user temporary tables | 7-30 days | cost control |

## Rules

- Do not apply aggressive expiration to audit logs.
- Do not delete raw data needed for active backfill or incident recovery.
- Do not retain Restricted data forever without reason.
- Retention changes must be reviewed for compliance and recovery impact.

