# Portfolio Red Flags

## Severe Red Flags

- No README.
- README has no run commands.
- Project only contains notebooks.
- No data model or grain explanation.
- No data quality checks.
- Credentials or secrets committed.
- Cannot explain what happens if the pipeline reruns.
- Cannot explain duplicate handling.
- Cannot explain why tools were chosen.

## Data Engineering Specific Red Flags

- Pipeline writes final output but does not preserve raw data.
- Fact table grain is unclear.
- Revenue metric is calculated differently in multiple places.
- Joins can multiply rows but README does not mention it.
- Incremental load uses `created_at` only and ignores updates.
- No handling for late-arriving data.
- No backfill story.
- No failure handling.
- No cost/scaling section.

## Interview Red Flags

- Candidate says "I used Kafka because it is popular."
- Candidate cannot explain offset or duplicate handling.
- Candidate cannot explain dbt vs Airflow.
- Candidate cannot explain partitioning.
- Candidate cannot describe one real bug or failure scenario.
- Candidate cannot reproduce the project locally.

## Fix Priority

1. Add run commands.
2. Add architecture diagram.
3. Add grain/data model docs.
4. Add quality checks.
5. Add failure handling.
6. Add trade-offs.
7. Add cost/scaling notes.

