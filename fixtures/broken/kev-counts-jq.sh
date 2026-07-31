#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <cisa-k-ev-json-path>" >&2
    exit 2
fi

JSON_PATH="$1"

total=$(jq -r '.[] | 1' "$JSON_PATH" 2>/dev/null | wc -l)
ransomware=$(jq -r '[.[] | select(.knownRansomwareCampaignUse == "Known")] | length' "$JSON_PATH")

echo "total: $total"
echo "ransomware: $ransomware"
