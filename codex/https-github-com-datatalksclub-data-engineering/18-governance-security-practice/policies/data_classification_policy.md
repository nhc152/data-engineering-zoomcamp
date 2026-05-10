# Data Classification Policy

## Purpose

Classify data so access, masking, retention, and sharing decisions are consistent.

## Classification Levels

| Level | Description | Examples | Default Access |
|---|---|---|---|
| Public | Safe to publish externally | public docs, public product catalog | open |
| Internal | Internal business data with low sensitivity | non-sensitive operational metrics | employees by role |
| Confidential | Business-sensitive data | revenue, margin, vendor terms, fraud scores | approved teams |
| Restricted | PII, payment, legal, secrets | email, phone, address, national ID, credentials | tightly restricted |

## PII Examples

- Full name.
- Email.
- Phone.
- Address.
- National ID.
- Payment details.
- Precise location.
- Device identifiers.
- IP address, depending on jurisdiction and policy.

## Required Controls by Level

| Control | Public | Internal | Confidential | Restricted |
|---|---|---|---|---|
| Owner required | yes | yes | yes | yes |
| Catalog description | yes | yes | yes | yes |
| Access approval | no | role-based | explicit approval | explicit approval + justification |
| Masking | no | optional | sometimes | required by default |
| Audit logs | optional | yes | yes | yes |
| Retention policy | yes | yes | yes | yes |
| External sharing | allowed | review | approval | legal/security approval |

## Production Rule

If classification is unknown, treat the dataset as Restricted until reviewed.

