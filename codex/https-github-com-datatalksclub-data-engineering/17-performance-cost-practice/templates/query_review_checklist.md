# Query Review Checklist

Use this checklist before approving expensive warehouse queries.

## Scan Control

- [ ] Query selects only needed columns.
- [ ] Partitioned tables have partition filters.
- [ ] Date filters use partition columns directly.
- [ ] Query avoids scanning raw data for dashboards.

## Join Safety

- [ ] Grain of each input table is known.
- [ ] Join key on dimension side is unique if expected.
- [ ] One-to-many joins are intentional.
- [ ] Metrics are not duplicated after join.

## Materialization

- [ ] Repeated dashboard query uses a mart.
- [ ] Heavy intermediate results are materialized if reused.
- [ ] Full refresh is justified.

## Ownership

- [ ] Owner/team label exists.
- [ ] Environment label exists.
- [ ] Cost center/project label exists.

## Reliability

- [ ] Query has expected row count range.
- [ ] Query has freshness expectations.
- [ ] Query has rollback/reprocess plan if it writes data.

