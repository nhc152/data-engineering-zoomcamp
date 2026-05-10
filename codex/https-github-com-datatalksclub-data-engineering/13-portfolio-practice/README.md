# Portfolio Practice Lab

## Goal

Turn your Data Engineering practice projects into job-ready portfolio artifacts.

This lab is not resume advice. It is a packaging and review system for proving that you can design, build, debug, and explain production-style data pipelines.

## What This Lab Teaches

- Architecture-first README writing.
- Data model and grain documentation.
- Run commands and reproducibility.
- Data quality documentation.
- Failure handling and runbook writing.
- Cost and scaling notes.
- Trade-off explanation.
- Project storytelling for interviews.
- Concise Q&A for hiring managers.

## Required Portfolio Artifacts

Every serious Data Engineering project should have:

- Architecture diagram.
- README with exact setup and run commands.
- Data source explanation.
- Data model and grain section.
- Pipeline flow.
- Data quality checks.
- Incremental/backfill strategy.
- Failure handling.
- Cost/scaling notes.
- Trade-offs.
- Future improvements.

## Folder Structure

```text
13-portfolio-practice/
  README.md
  templates/
    README_TEMPLATE.md
    ARCHITECTURE_DIAGRAM_TEMPLATE.md
    DATA_MODEL_TEMPLATE.md
    RUNBOOK_TEMPLATE.md
    FAILURE_HANDLING_TEMPLATE.md
    INTERVIEW_ANSWER_TEMPLATE.md
  rubrics/
    PROJECT_SCORING_RUBRIC.md
    RED_FLAGS.md
  checklists/
    PORTFOLIO_CHECKLIST.md
    README_REVIEW_CHECKLIST.md
    INTERVIEW_READINESS_CHECKLIST.md
  examples/
    batch_elt_project_packaging.md
    streaming_project_packaging.md
    spark_project_packaging.md
```

## Recommended Workflow

1. Pick one project.
2. Fill `templates/README_TEMPLATE.md`.
3. Fill `templates/ARCHITECTURE_DIAGRAM_TEMPLATE.md`.
4. Fill `templates/DATA_MODEL_TEMPLATE.md`.
5. Fill `templates/RUNBOOK_TEMPLATE.md`.
6. Score the project with `rubrics/PROJECT_SCORING_RUBRIC.md`.
7. Check red flags with `rubrics/RED_FLAGS.md`.
8. Practice interview with `templates/INTERVIEW_ANSWER_TEMPLATE.md`.
9. Review using all checklists.

## Project Types to Package

### Project 1 - Batch ELT

Target architecture:

```text
API/CSV -> Python ingestion -> raw storage -> warehouse -> dbt marts -> quality checks -> orchestration
```

This should be your main portfolio project.

### Project 2 - Streaming

Target architecture:

```text
producer -> Kafka topic -> idempotent consumer -> PostgreSQL/BigQuery sink -> DLQ/replay notes
```

This proves you understand streaming correctness.

### Project 3 - Spark Batch

Target architecture:

```text
raw files -> Spark transform -> partitioned Parquet -> marts -> performance notes
```

This proves scale and file/lake thinking.

## Standard for a Strong Project

A strong project does not just run. It explains:

- why this architecture exists
- what can fail
- how to debug it
- how data correctness is protected
- how cost and scale are controlled
- what trade-offs were made

If the README cannot answer those, the project is not portfolio-ready.

