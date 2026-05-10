"""Broken example: final file is written directly.

If a process crashes while writing this file, downstream readers can see a
partial file. The solution is temp-write then atomic rename.
"""

from pathlib import Path


def broken_write(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as file:
        file.write('{"order_id":"O1"}\n')
        raise RuntimeError("crash while writing final file")


if __name__ == "__main__":
    broken_write(Path("data/processed/broken_partial.jsonl"))

