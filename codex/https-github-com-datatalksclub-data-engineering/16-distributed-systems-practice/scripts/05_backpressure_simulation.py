from collections import deque

from common import explain


def simulate(upstream_rate: int, downstream_rate: int, ticks: int) -> list[dict]:
    queue = deque()
    metrics = []
    next_event_id = 1

    for tick in range(1, ticks + 1):
        produced = []
        for _ in range(upstream_rate):
            event = f"evt-{next_event_id:03d}"
            queue.append(event)
            produced.append(event)
            next_event_id += 1

        consumed = []
        for _ in range(min(downstream_rate, len(queue))):
            consumed.append(queue.popleft())

        metrics.append(
            {
                "tick": tick,
                "produced": len(produced),
                "consumed": len(consumed),
                "lag": len(queue),
            }
        )
    return metrics


def print_metrics(title: str, metrics: list[dict]) -> None:
    print(f"\n== {title} ==")
    print("tick | produced | consumed | lag")
    for row in metrics:
        print(f"{row['tick']} | {row['produced']} | {row['consumed']} | {row['lag']}")


def main() -> None:
    print("Scenario: downstream is slower than upstream, so lag grows.")

    slow = simulate(upstream_rate=5, downstream_rate=2, ticks=8)
    print_metrics("Slow downstream", slow)

    scaled = simulate(upstream_rate=5, downstream_rate=5, ticks=8)
    print_metrics("Scaled downstream catches up", scaled)

    throttled = simulate(upstream_rate=2, downstream_rate=2, ticks=8)
    print_metrics("Throttled upstream prevents lag growth", throttled)

    explain(
        "Prevention strategy",
        [
            "Monitor lag and processing latency.",
            "Scale consumers/workers when safe.",
            "Throttle upstream when downstream is saturated.",
            "Use DLQ/quarantine for poison events so one bad event does not block progress.",
            "In Spark, skew can look like backpressure because one stage blocks downstream stages.",
            "In orchestration, queued tasks indicate worker or dependency bottlenecks.",
        ],
    )


if __name__ == "__main__":
    main()

