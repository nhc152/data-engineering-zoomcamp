# Data Engineering Project Scoring Rubric

Score your project out of 100.

## 1. Problem and Scope - 10 points

| Score | Criteria |
|---|---|
| 0-3 | vague learning project, no business/data problem |
| 4-7 | problem exists but scope is fuzzy |
| 8-10 | clear problem, clear users, clear outputs |

## 2. Architecture - 15 points

| Score | Criteria |
|---|---|
| 0-5 | no architecture or just tool list |
| 6-10 | data flow exists but lacks failure/quality boundaries |
| 11-15 | architecture shows source, raw, transform, quality, serving, orchestration |

## 3. Reproducibility - 15 points

| Score | Criteria |
|---|---|
| 0-5 | cannot run from README |
| 6-10 | partial setup, manual assumptions |
| 11-15 | exact commands, env example, Docker or clear local setup |

## 4. Data Modeling - 15 points

| Score | Criteria |
|---|---|
| 0-5 | no grain, no model docs |
| 6-10 | basic tables but unclear metrics |
| 11-15 | facts/dims/marts, grain, keys, metric definitions |

## 5. Data Quality - 15 points

| Score | Criteria |
|---|---|
| 0-5 | no checks |
| 6-10 | basic not null/unique checks |
| 11-15 | uniqueness, relationships, accepted values, freshness, reconciliation |

## 6. Reliability and Operations - 15 points

| Score | Criteria |
|---|---|
| 0-5 | no failure handling |
| 6-10 | mentions retry/backfill but not implemented/explained |
| 11-15 | idempotency, retry, backfill, runbook, failure matrix |

## 7. Cost and Scaling - 10 points

| Score | Criteria |
|---|---|
| 0-3 | no cost/scaling notes |
| 4-7 | mentions scaling generally |
| 8-10 | partitioning, query cost, bottlenecks, 10x data plan |

## 8. Interview Readiness - 5 points

| Score | Criteria |
|---|---|
| 0-2 | cannot explain beyond tools |
| 3-4 | can explain architecture |
| 5 | can explain architecture, trade-offs, failures, improvements |

## Score Interpretation

| Score | Meaning |
|---|---|
| 0-40 | tutorial-level, not portfolio-ready |
| 41-65 | decent learning project, weak for interviews |
| 66-80 | good junior DE portfolio project |
| 81-90 | strong DE project |
| 91-100 | excellent, production-minded portfolio artifact |

