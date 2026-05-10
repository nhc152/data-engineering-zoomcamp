# Broken Scenario 02 - Manual Change Causes Drift

## Symptom

Terraform plan shows an IAM or lifecycle change that nobody expects.

Example:

```text
~ public_access_prevention: "enforced" -> "inherited"
```

## Cause

Someone changed bucket settings manually in the GCP console.

## Risk

- Security guardrail removed.
- Terraform may revert it on next apply.
- Nobody knows why the change happened.

## Required Response

Follow `docs/drift_response_runbook.md`.

