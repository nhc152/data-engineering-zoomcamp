# Solution: Partial File Write

Correct behavior:

- Write to a temporary path.
- Close and flush the file.
- Atomically rename temp file to final path.

Implemented in:

```text
src/extract.py::write_raw_copy
```

Production notes:

- Data lake pipelines often add a `_SUCCESS` marker after all files are written.
- Downstream readers should read only completed partitions.

