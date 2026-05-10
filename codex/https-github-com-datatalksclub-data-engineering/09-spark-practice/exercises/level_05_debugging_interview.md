# Level 05 - Debugging and Interview Scenarios

## Goal

Practice explaining Spark failures like a production engineer.

## Scenarios

1. `broken/01_collect_crash_bad.py`
2. `broken/02_skewed_join_bad.py`
3. `broken/03_small_files_bad.py`
4. `broken/04_overwrite_bad.py`
5. `broken/05_executor_oom_bad.py`

## Tasks

For each scenario:

1. Run or inspect the broken job.
2. Describe the symptom.
3. Identify root cause.
4. Inspect the Spark plan/UI/logs when possible.
5. Run the matching solution.
6. Explain the trade-off of the fix.

## Expected Interview Answers

You should be able to answer:

- Why is `collect()` dangerous?
- What is shuffle and why is it expensive?
- How do you identify skew?
- How do you fix too many small files?
- Why is overwrite dangerous in backfills?
- Why is `coalesce(1)` a bad default?

