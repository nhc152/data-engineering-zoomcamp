# Level 03 - Small Files and Compaction

## Goal

Experience how many small files affect query planning and file listing.

## Tasks

1. Run `python src/convert_formats.py`.
2. Count files under `data/lake/orders_small_files/`.
3. Count files under `data/lake/orders_compacted/`.
4. Run `python src/query_examples.py`.
5. Compare timings for `small_files_one_month` and `compacted_one_month`.

## Expected Learning

- Small files add metadata/listing/planning overhead.
- Compaction reduces file count.
- Too-large files can reduce parallelism, so compaction needs target size.

## Questions

- What creates small files in streaming jobs?
- Why can partitioning make small files worse?
- What compaction schedule would you choose for daily events?

