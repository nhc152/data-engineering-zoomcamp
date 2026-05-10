# Incident Example - Dashboard Leaks Customer Email

## Summary

A customer analytics dashboard exposed raw customer email to a broad BI viewer group.

## Severity

P1 because Restricted PII was exposed outside approved users.

## Data Classification

Restricted.

## Impact

- Raw customer email visible in dashboard.
- BI viewer group had broader access than intended.
- Exposure window: 2 days.

## Root Cause

Dashboard used a mart that included raw email. The mart had no masking policy and dashboard publication review did not check PII columns.

## Immediate Actions

- Removed email column from dashboard.
- Restricted dashboard access.
- Reviewed audit logs for viewers.
- Created masked customer mart.

## Prevention

- Add column classification to mart docs.
- Add dashboard PII review checklist.
- Use masked customer mart for BI.
- Restrict raw PII access.

