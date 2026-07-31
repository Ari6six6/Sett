#!/usr/bin/env python3
"""GitHub-flavoured markdown table generator."""

def table(rows):
    """
    Return a GitHub-flavoured markdown table string for the given rows.

    Args:
        rows: List of dicts, each with keys "model", "gym", "score".

    Returns:
        Markdown table as a string.
    """
    if not rows:
        return ""

    header = "| model | gym | score |"
    separator = "|---|---|---|"
    rows_str = [f"| {row['model']} | {row['gym']} | {row['score']} |" for row in rows]

    return "\n".join([header, separator] + rows_str)
