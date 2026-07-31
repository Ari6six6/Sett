#!/usr/bin/env python3
"""
Read a SETT .probe spec and extract checks.

Each check begins with a line starting "check:" and continues until a blank line
or a line starting "## ".
"""
import re
from typing import Dict


def checks(path: str) -> Dict[str, str]:
    """
    Read a SETT .probe spec file and return a dict mapping point id to check text.

    Parameters
    ----------
    path : str
        Path to the .probe spec file.

    Returns
    -------
    Dict[str, str]
        Mapping from point_id to the full check text for that point.
    """
    result = {}

    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i]

        # Look for a line starting with "check:"
        if line.startswith('check:'):
            # Extract point id from the check line
            # Format is typically "check: <point_id>: <text>" or similar
            match = re.match(r'^check:\s*(.+?)\s*:\s*(.*)', line)
            if not match:
                # Fallback: check id is everything before the colon on the check line
                check_id = line[len('check:'):].strip()
                check_text = ''
            else:
                check_id = match.group(1).strip()
                check_text = match.group(2)

            # Collect continuation lines
            i += 1
            while i < len(lines):
                next_line = lines[i].rstrip('\n')
                # Stop at blank line or section header
                if next_line == '' or next_line.startswith('## '):
                    break
                # Strip the leading "check:" prefix if present
                if next_line.startswith('check:'):
                    next_line = next_line[len('check:'):].strip()
                check_text += '\n' + next_line
                i += 1

            result[check_id] = check_text.strip()
        else:
            i += 1

    return result
