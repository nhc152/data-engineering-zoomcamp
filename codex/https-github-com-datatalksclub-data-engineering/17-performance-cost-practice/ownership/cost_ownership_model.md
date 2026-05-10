# Cost Ownership Model

Cost optimization fails if nobody owns the bill.

## Required Labels

| Label | Example | Purpose |
|---|---|---|
| `owner` | `data-platform` | Who responds to cost issues |
| `domain` | `finance` | Business/data domain |
| `environment` | `dev`, `staging`, `prod` | Separate experimental and production cost |
| `workload_type` | `dashboard`, `dbt`, `spark`, `kafka`, `ad_hoc` | Attribution by workload |
| `criticality` | `low`, `medium`, `high` | Helps prioritize optimization |
| `cost_center` | `analytics` | Chargeback/showback |

## Ownership Questions

- Who owns this job/dashboard/table?
- Who receives cost alerts?
- Who can approve full refresh/backfill?
- Who can change retention?
- Who validates optimization did not change business meaning?

## Anti-patterns

- BigQuery jobs run as one shared service account with no labels.
- Spark clusters have no owner tag.
- Kafka topics have no retention owner.
- Dashboards query raw tables without team ownership.
- Dev and prod cost mixed together.

## Guardrails

- Require labels on scheduled jobs.
- Alert by owner.
- Review top 10 cost workloads weekly.
- Require approval for heavy backfills.
- Set retention by topic/table owner.

