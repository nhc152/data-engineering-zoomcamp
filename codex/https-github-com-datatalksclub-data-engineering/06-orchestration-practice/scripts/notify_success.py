from __future__ import annotations

from common import log_event, parse_args


def main() -> None:
    args = parse_args()
    log_event("notify_success", args.run_date, "success", "pipeline completed successfully")


if __name__ == "__main__":
    main()

