#!/usr/bin/env python3
"""
Read a SETT state.tsv file and return counts of last recorded verdicts.

The file should contain tab-separated data where each row has at least:
  - id: identifier for each record
  - verdict: one of PASS, FAIL, ERROR (case-insensitive)

This function counts only the LAST recorded verdict for each ID.
"""

import sys
import re


def summary(path):
    """
    Read a SETT state.tsv file and return a dict with counts of last recorded verdicts.
    
    Args:
        path: Path to the SETT state.tsv file
        
    Returns:
        dict with keys "pass", "fail", "error" and integer counts
    """
    # Set to store last verdict for each id
    last_verdicts = {}
    
    # Pattern to match the three valid verdicts
    verdict_pattern = re.compile(r'^[A-Z]{4}$', re.MULTILINE)
    
    with open(path, 'r') as f:
        for line_num, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            
            parts = line.split('\t')
            
            # Skip if line doesn't have at least 2 columns
            if len(parts) < 2:
                continue
            
            id_field = parts[0]
            verdict = parts[1]
            
            # Validate verdict is one of the three expected values
            if verdict not in ('PASS', 'FAIL', 'ERROR'):
                continue
            
            # Store this as the last verdict for this id
            last_verdicts[id_field] = verdict
    
    # Count verdicts
    counts = {"pass": 0, "fail": 0, "error": 0}
    
    for verdict in last_verdicts.values():
        if verdict == "PASS":
            counts["pass"] += 1
        elif verdict == "FAIL":
            counts["fail"] += 1
        elif verdict == "ERROR":
            counts["error"] += 1
    
    return counts


def main():
    if len(sys.argv) != 2:
        print("Usage: python 2.py <state.tsv>")
        sys.exit(1)
    
    path = sys.argv[1]
    
    try:
        result = summary(path)
        print(result)
    except FileNotFoundError:
        print(f"Error: File not found: {path}", file=sys.stderr)
        sys.exit(1)
    except PermissionError:
        print(f"Error: Permission denied: {path}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
