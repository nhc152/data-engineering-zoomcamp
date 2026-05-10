# Broken Scenario 05 - Dashboard Leaks Customer Email

## Symptom

A BI dashboard visible to a broad group displays raw customer email.

## Root Cause

- Dashboard reads raw or insufficiently masked mart.
- No column classification check before publication.
- BI access policy did not restrict PII.

## Fix

- Remove email from dashboard.
- Replace with masked email or customer token if needed.
- Restrict dashboard access while investigating.
- Add dashboard publication checklist.

