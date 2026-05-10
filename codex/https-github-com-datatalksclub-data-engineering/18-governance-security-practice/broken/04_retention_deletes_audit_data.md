# Broken Scenario 04 - Retention Deletes Audit Data

## Symptom

An incident investigation needs audit logs from 90 days ago, but lifecycle policy deleted them after 30 days.

## Root Cause

Retention policy optimized storage cost without considering investigation/compliance needs.

## Impact

- Cannot determine who accessed sensitive data.
- Incident response incomplete.
- Compliance gap.

## Fix

- Separate audit log retention from temp data retention.
- Review retention policy with security/legal.
- Add policy-as-code or review gate for audit log lifecycle changes.

