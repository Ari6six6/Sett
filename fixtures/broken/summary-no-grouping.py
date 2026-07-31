#!/usr/bin/env python3
"""Summary of SETT state.tsv verdicts."""

import sys
from collections import defaultdict


def summary(path: str) -> dict[str, int]:
    """
    Read a SETT state.tsv and return counts of last recorded verdicts.

    Args:
        path: Path to state.tsv file

    Returns:
        Dict with keys "pass", "fail", "error" mapping to counts of ids
        whose final verdict is that value.

    The state.tsv format is expected to have columns:
        - id: identifier (unique per test case)
        - verdict: one of PASS, FAIL, ERROR (upper case)
        - timestamp: (optional) timestamp for ordering
        - ... other columns ...

    The last recorded verdict for each id is determined by timestamp order.
    """
    counts: defaultdict[str, int] = defaultdict(int)

    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                # First line is header
                if line.startswith("#") or line.startswith("id") or line.startswith("verdict"):
                    continue

                parts = line.split("\t")
                if len(parts) < 2:
                    continue

                # Default: last column is verdict
                # If timestamp exists, second-to-last is verdict, last is timestamp
                # Adjust based on actual file structure
                if len(parts) >= 3 and parts[-2].upper() in ("PASS", "FAIL", "ERROR"):
                    verdict = parts[-2].strip().upper()
                else:
                    verdict = parts[-1].strip().upper()

                if verdict in ("PASS", "FAIL", "ERROR"):
                    counts[verdict] += 1

    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {path}")
    except Exception as e:
        raise IOError(f"Error reading {path}: {e}")

    # Return in predictable order
    return {
        "pass": counts.get("PASS", 0),
        "fail": counts.get("FAIL", 0),
        "error": counts.get("ERROR", 0),
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <state.tsv>", file=sys.stderr)
        sys.exit(1)

    try:
        result = summary(sys.argv[1])
        print(f'pass: {result["pass"]}')
        print(f'fail: {result["fail"]}')
        print(f'error: {result["error"]}')
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
