#!/usr/bin/env python3
"""
Read a SETT .probe spec and return the fraction of points whose "do:" line
contains an absolute path starting with /home/.

Probe spec format:
    ## <id> <slug>
    do: <command>
    ...
"""

from pathlib import Path
from typing import List, Tuple


def points(path: Path) -> List[Tuple[str, str]]:
    """Read a SETT .probe spec and return a list of (id, slug) tuples in file order.

    Args:
        path: Path to the probe spec file

    Returns:
        List of (id, slug) tuples where:
        - id is the first token after "## " (e.g., "1", "11")
        - slug is the rest of the line (e.g., "stix-bytes")
    """
    result = []
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('## '):
                # Split on first space to separate id from slug
                parts = line[3:].split(' ', 1)
                if len(parts) == 2:
                    point_id, slug = parts
                    result.append((point_id, slug.strip()))
    return result


def grounded_ratio(path: Path) -> float:
    """
    Read a SETT .probe spec and return the fraction of points whose "do:" line
    contains an absolute path starting with /home/.

    Args:
        path: Path to the probe spec file

    Returns:
        A float value between 0.0 and 1.0 representing the fraction of grounded points.
    """
    points_list = points(path)
    total_points = len(points_list)
    grounded_points = 0

    if total_points == 0:
        return 0.0

    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Process each point in order
    idx = 0
    for point_id, slug in points_list:
        # Skip ahead to the start of this point
        while idx < len(lines) and not lines[idx].startswith('## '):
            idx += 1

        # Find the do: line for this point (next line after header)
        do_line = None

        idx += 1  # Move past the header
        while idx < len(lines) and not lines[idx].startswith('## '):
            if lines[idx].startswith('do: '):
                do_line = lines[idx]
                break
            idx += 1

        # Check if this do: line contains a path starting with /home/
        if do_line:
            path_part = do_line[4:].strip()  # Everything after "do: "
            if path_part.startswith('/home/'):
                grounded_points += 1

    return grounded_points / total_points


def main():
    """Command-line interface for testing."""
    import sys

    if len(sys.argv) != 2:
        print("Usage: python 4.py <probe-spec>")
        sys.exit(1)

    path = Path(sys.argv[1])

    if not path.exists():
        print(f"Error: File not found: {path}", file=sys.stderr)
        sys.exit(1)

    try:
        ratio = grounded_ratio(path)
        print(ratio)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
