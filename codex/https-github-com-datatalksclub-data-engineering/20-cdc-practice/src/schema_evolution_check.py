import argparse
import json
from pathlib import Path


EXPECTED_AFTER_KEYS = {
    "order_id",
    "customer_id",
    "order_status",
    "order_amount",
    "updated_at",
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--events", required=True)
    args = parser.parse_args()

    path = Path(args.events)
    added: set[str] = set()
    missing: set[str] = set()

    with path.open("r", encoding="utf-8") as file:
        for line in file:
            event = json.loads(line)
            payload = event.get("payload")
            if not payload or not payload.get("after"):
                continue
            keys = set(payload["after"].keys())
            added.update(keys - EXPECTED_AFTER_KEYS)
            missing.update(EXPECTED_AFTER_KEYS - keys)

    print("Expected keys:", sorted(EXPECTED_AFTER_KEYS))
    print("Added keys:", sorted(added))
    print("Missing keys:", sorted(missing))

    if added or missing:
        print("SCHEMA DRIFT DETECTED")
    else:
        print("No schema drift detected")


if __name__ == "__main__":
    main()

