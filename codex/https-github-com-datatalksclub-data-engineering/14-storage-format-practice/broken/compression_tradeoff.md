# Broken Scenario - Compression Trade-off

## Symptom

Storage cost is lower after switching compression, but jobs become slower or CPU-heavy.

## Root Cause

Compression reduces bytes but can increase CPU cost. Different codecs have different trade-offs.

General pattern:

- Snappy: balanced, fast.
- Gzip: smaller files, slower CPU.
- Zstd: strong compression, tunable, often good for lake analytics.

## Diagnostic

Run:

```bash
python src/convert_formats.py
python src/query_examples.py
```

Compare:

- file size report
- query timing report
- CPU behavior if available

## Prevention

- Choose compression based on workload.
- Benchmark with representative data.
- Do not optimize storage cost only.

