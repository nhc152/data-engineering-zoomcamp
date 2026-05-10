# Exercise 03 - IAM Matrix

## Goal

Practice least-privilege IAM for data pipelines.

## Tasks

1. Read `docs/iam_matrix.md`.
2. Identify which service account loads raw data.
3. Identify which service account transforms marts.
4. Explain why BI users should not read raw.
5. Explain why `roles/editor` is dangerous.

## Expected Output

Write:

```text
notes/iam_review.md
```

Include:

- service account purpose
- allowed roles
- forbidden roles
- blast radius if compromised

