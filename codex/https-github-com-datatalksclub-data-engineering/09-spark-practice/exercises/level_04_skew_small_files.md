# Level 04 - Skew and Small Files

## Goal

Practice diagnosing two common Spark production problems: skew and small files.

## Tasks

1. Run `src/05_skew_demo.py --sleep-seconds 60`.
2. Open Spark UI at `http://localhost:4040`.
3. Check whether some customer groups are much larger.
4. Run `src/06_small_files_compaction.py`.
5. Compare output file counts in `bad_many_files` vs `compacted`.

## Expected Learning

- Skew means one or few keys dominate data distribution.
- A skewed key can make one task much slower.
- Too many small files slow planning and downstream reads.
- Compaction reduces file count but costs compute.

## Interview Question

How would you debug a Spark stage where 199 tasks finish fast and 1 task runs for 30 minutes?

