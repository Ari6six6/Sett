#!/usr/bin/env python3
"""
SETT state.tsv parser — returns latest verdict for each id.

State.tsv format:
    timestamp    id    verdict    note
    (tab-separated)

The function reads the file once and keeps the last entry for each id,
returning {id: verdict}.
"""

from pathlib import Path
from typing import Dict


def latest(path: Path) -> Dict[str, str]:
    """
    Read a SETT state.tsv file and return a dict mapping each id to its
    most recent verdict in file order.

    Args:
        path: Path to the state.tsv file (or str/PathLike).

    Returns:
        A dict: {id: verdict}.
    """
    result = {}

    for line in path.read_text(encoding="utf-8").splitlines():
        # Skip empty lines
        if not line.strip():
            continue

        parts = line.strip().split("\t")
        if len(parts) < 3:
            continue  # Skip malformed lines

        _timestamp, id_, verdict, *note = parts
        result[id_] = verdict

    return result
