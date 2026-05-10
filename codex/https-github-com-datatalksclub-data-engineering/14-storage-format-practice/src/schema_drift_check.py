import json
from pathlib import Path


RAW_DIR = Path("data/raw")


def infer_jsonl_keys(path: Path, sample_size: int = 1000) -> set[str]:
    keys: set[str] = set()
    with path.open("r", encoding="utf-8") as file:
        for idx, line in enumerate(file):
            if idx >= sample_size:
                break
            keys.update(json.loads(line).keys())
    return keys


def main() -> None:
    expected_path = RAW_DIR / "orders.jsonl"
    drift_path = RAW_DIR / "orders_schema_drift.jsonl"
    if not expected_path.exists() or not drift_path.exists():
        raise FileNotFoundError("Run `python src/generate_data.py --rows 50000` first.")

    expected = infer_jsonl_keys(expected_path)
    actual = infer_jsonl_keys(drift_path)

    added = sorted(actual - expected)
    removed = sorted(expected - actual)

    print("Expected keys:", sorted(expected))
    print("Actual keys:", sorted(actual))
    print("Added keys:", added)
    print("Removed keys:", removed)

    if added or removed:
        print("SCHEMA DRIFT DETECTED")
    else:
        print("No schema drift detected")

    print("Type drift note: this script detects keys only. In production, validate data types too.")


if __name__ == "__main__":
    main()

