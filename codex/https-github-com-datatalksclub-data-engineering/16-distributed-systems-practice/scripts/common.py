import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / "tmp"
DATA = ROOT / "data"


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def reset_db(name: str) -> sqlite3.Connection:
    TMP.mkdir(exist_ok=True)
    db_path = TMP / name
    if db_path.exists():
        db_path.unlink()
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


def read_jsonl(path: Path) -> list[dict]:
    records = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def print_rows(conn: sqlite3.Connection, title: str, query: str) -> None:
    print(f"\n== {title} ==")
    rows = conn.execute(query).fetchall()
    if not rows:
        print("(no rows)")
        return
    columns = rows[0].keys()
    print(" | ".join(columns))
    for row in rows:
        print(" | ".join(str(row[col]) for col in columns))


def explain(title: str, lines: list[str]) -> None:
    print(f"\n## {title}")
    for line in lines:
        print(f"- {line}")

