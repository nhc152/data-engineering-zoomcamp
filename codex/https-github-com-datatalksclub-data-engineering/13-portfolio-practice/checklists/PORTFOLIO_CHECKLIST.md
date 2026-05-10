# Portfolio Checklist

## Repository

- [ ] Project name is clear.
- [ ] README starts with problem and architecture.
- [ ] `.env.example` exists if env vars are needed.
- [ ] No secrets committed.
- [ ] Generated data/cache files are ignored.
- [ ] Folder structure is understandable.

## Architecture

- [ ] Source is identified.
- [ ] Raw layer exists or is justified as unnecessary.
- [ ] Transform layer is clear.
- [ ] Serving/mart layer is clear.
- [ ] Orchestration is shown if used.
- [ ] Quality checks are shown.

## Data Model

- [ ] Every important table has grain.
- [ ] Primary/business keys are documented.
- [ ] Fact and dimension tables are explained.
- [ ] Metrics are defined.
- [ ] Join risks are mentioned.

## Reliability

- [ ] Pipeline can rerun safely.
- [ ] Duplicate handling is documented.
- [ ] Late-arriving data is considered.
- [ ] Backfill strategy exists.
- [ ] Runbook exists.

## Quality

- [ ] Unique checks.
- [ ] Not null checks.
- [ ] Relationship checks.
- [ ] Accepted values checks.
- [ ] Freshness checks.
- [ ] Reconciliation checks.

## Cost and Scale

- [ ] Partitioning/indexing explained.
- [ ] Query cost considerations explained.
- [ ] Bottleneck identified.
- [ ] 10x data plan exists.

## Interview

- [ ] 60-second explanation ready.
- [ ] 5-minute explanation ready.
- [ ] Trade-offs ready.
- [ ] Failure story ready.
- [ ] Improvement plan ready.

