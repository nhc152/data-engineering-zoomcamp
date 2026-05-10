# Level 02 - Sources and Staging

## Goal

Practice raw source declaration and staging model design.

## Tasks

1. Inspect `models/staging/ecommerce/_ecommerce__sources.yml`.
2. Run `dbt source freshness`.
3. Inspect all `stg_ecommerce__*.sql` models.
4. Run `dbt build --select staging`.
5. Check generated staging schemas/tables.

## Expected Learning

- Staging models clean, cast, rename, and deduplicate source data.
- Staging models should not contain large business aggregations.
- Source freshness catches stale raw data.

## Questions

- Why is `stg_ecommerce__orders` deduplicated?
- Why should staging use `source()`?
- What would happen if raw schema changed?

