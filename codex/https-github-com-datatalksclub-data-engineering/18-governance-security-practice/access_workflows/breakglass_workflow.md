# Breakglass Workflow

## Purpose

Emergency access for incidents where standard approval would delay critical response.

## Rules

- Use only for active incidents.
- Must create incident ticket.
- Must specify scope and duration.
- Must expire automatically.
- Must be reviewed after incident.

## Required Fields

```text
Incident ID:
Requester:
Dataset/table:
Columns:
Reason:
Start time:
Expiration time:
Approver:
Post-incident review owner:
```

## Audit

After the incident:

- review queries/actions
- confirm access removed
- document why breakglass was needed
- add prevention if normal access process was inadequate

