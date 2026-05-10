# Level 02 - IAM Matrix

## Goal

Practice least-privilege access design.

## Tasks

1. Read `matrices/iam_matrix.md`.
2. Identify which roles can access raw Restricted data.
3. Identify which service accounts can write marts.
4. Remove unnecessary permissions from a hypothetical analyst group.
5. Write a least-privilege decision for `svc-ingestion-orders`.

## Expected Output

Explain why `svc-ingestion-orders` should not have:

- project Owner
- access to finance marts
- IAM admin
- dashboard read access

