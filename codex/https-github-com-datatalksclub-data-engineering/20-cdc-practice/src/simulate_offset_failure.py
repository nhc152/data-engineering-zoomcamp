import json
from pathlib import Path


def main() -> None:
    event = json.loads(Path("events/02_change_stream_orders.jsonl").read_text(encoding="utf-8").splitlines()[0])
    lsn = event["payload"]["source"]["lsn"]
    event_id = event["event_id"]

    print("Simulating broken consumer behavior:")
    print(f"1. Consumer reads event {event_id} at LSN {lsn}.")
    print("2. Consumer commits offset BEFORE writing to sink.")
    print("3. Process crashes.")
    print("4. On restart, consumer resumes after committed offset.")
    print("5. Sink never receives the event. This is data loss.")
    print()
    print("Correct behavior:")
    print("1. Write raw changelog and current-state sink in a transaction.")
    print("2. Commit sink transaction.")
    print("3. Then commit offset.")
    print("4. If crash happens before offset commit, event may replay, so sink must be idempotent.")


if __name__ == "__main__":
    main()

