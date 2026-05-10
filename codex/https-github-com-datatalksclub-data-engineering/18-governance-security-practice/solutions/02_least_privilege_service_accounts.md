# Solution - Least Privilege Service Accounts

## Bad

```text
svc-data-pipeline: Project Owner
```

## Better

| Service Account | Permissions |
|---|---|
| `svc-ingestion-orders` | write raw orders bucket/path, write raw orders table |
| `svc-transform-dbt` | read raw/staging, write staging/marts |
| `svc-bi-dashboard` | read curated marts only |

## Review Checklist

- Does the service account need write access?
- Does it need raw PII?
- Does it need IAM admin?
- Can permission be dataset/path scoped?
- Is access logged?

