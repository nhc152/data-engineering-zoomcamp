# IAM Matrix

## Roles

| Role/Group | Purpose |
|---|---|
| `data-platform-admins` | manage platform resources |
| `data-engineers` | build pipelines and curated datasets |
| `analytics-engineers` | build marts and semantic models |
| `finance-analysts` | query finance marts |
| `product-analysts` | query product/customer behavior marts |
| `bi-viewers` | view approved dashboards |
| `raw-pii-breakglass` | temporary emergency raw PII access |
| `svc-ingestion-orders` | ingestion service account |
| `svc-transform-dbt` | transformation service account |
| `svc-bi-dashboard` | dashboard service account |

## Access Matrix

| Resource | data-engineers | analytics-engineers | finance-analysts | product-analysts | bi-viewers | svc-ingestion-orders | svc-transform-dbt |
|---|---|---|---|---|---|---|---|
| raw restricted bucket | read/write limited | no | no | no | no | write | read |
| raw BigQuery dataset | read limited | no | no | no | no | write | read |
| staging dataset | read/write | read | no | no | no | no | write |
| finance marts | read | read/write | read | no or limited | via dashboard | no | write |
| product marts | read | read/write | no or limited | read | via dashboard | no | write |
| audit logs | read limited | no | no | no | no | no | no |

## Least Privilege Rules

- Ingestion service account writes raw, does not write marts.
- dbt service account reads raw/staging and writes staging/marts.
- BI service account reads only curated marts.
- Analysts do not get raw PII by default.
- Breakglass access expires and must be reviewed.

## Anti-patterns

- Everyone gets project Owner.
- One service account is reused by every pipeline.
- BI dashboard reads raw Restricted data.
- Analysts can export raw customer tables.
- No expiration for temporary elevated access.

