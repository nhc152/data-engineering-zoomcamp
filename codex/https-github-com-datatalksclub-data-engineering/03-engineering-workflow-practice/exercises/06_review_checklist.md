# Exercise 06 - Data Pipeline Code Review

## Goal

Review a data pipeline change like a Data Engineer.

## Inputs

Review:

```text
broken/bad_pr_description.md
broken/accidental_prod_config.yml
broken/readme_missing_run_commands.md
```

Use:

```text
templates/CODE_REVIEW_CHECKLIST.md
templates/PULL_REQUEST_TEMPLATE.md
```

## Review Questions

For each broken file, answer:

1. What is risky?
2. What production incident could happen?
3. What information is missing?
4. What should be changed before merge?

## Expected Learning

Review is not just syntax checking. For data pipelines, review must cover:

- data impact
- grain change
- metric change
- backfill requirement
- rollback plan
- secrets/config risk
- reproducibility

