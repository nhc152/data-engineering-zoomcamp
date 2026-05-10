# Governance and Security Practice Lab

## Goal

Practice concrete data governance and security decisions for a modern Data Engineering platform.

This lab is policy/design-first. It does not require cloud credentials. The goal is to learn how to design access, classify data, mask PII, define retention, review IAM, and respond to incidents.

## What You Will Learn

- Data classification.
- PII handling.
- IAM matrix design.
- Least privilege.
- Human access vs service account access.
- Row-level access.
- Column-level masking.
- Tokenization/masking concepts.
- Audit logs.
- Retention policy.
- Incident response.
- Trade-off between self-service and control.

## Target Architecture

```text
source systems
  -> raw restricted zone
  -> staging controlled zone
  -> curated marts
  -> governed BI / ML / API access
```

Governance must be built into the platform. It is not a spreadsheet afterthought.

## Folder Structure

```text
18-governance-security-practice/
  README.md
  policies/
  matrices/
  access_workflows/
  incidents/
  runbook/
  exercises/
  broken/
  solutions/
```

## Core Rules

1. Raw data is restricted by default.
2. PII must be classified before publication.
3. BI users should read curated marts, not raw PII.
4. Service accounts should have least privilege.
5. Production access must be auditable.
6. Retention must protect both privacy and recovery needs.
7. Dashboards should not expose direct identifiers unless explicitly approved.

## Trade-off: Self-Service vs Control

Too little control:

- PII leaks.
- Everyone queries raw data differently.
- No owner or audit trail.
- Cost and compliance risk increase.

Too much control:

- Teams wait too long for access.
- Analysts export data locally.
- Shadow pipelines appear.
- Data platform becomes a bottleneck.

Good governance provides guardrails:

- Curated datasets for broad access.
- Raw restricted access with approval.
- Masked views for self-service.
- Clear owners and SLAs.
- Auditable exception process.

## Recommended Learning Order

1. Read `policies/data_classification_policy.md`.
2. Review `matrices/classification_matrix.md`.
3. Review `matrices/iam_matrix.md`.
4. Read masking and retention policies.
5. Work through `exercises/`.
6. Review `broken/` scenarios.
7. Compare with `solutions/`.
8. Write one incident response using the runbook.

## GitHub Deliverables

Your final notes should include:

- Data classification matrix.
- IAM matrix.
- Masking policy.
- Retention policy.
- Access request workflow.
- Incident response runbook.
- One completed PII incident report.

