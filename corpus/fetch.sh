#!/usr/bin/env bash
# fetch — put the ground back under the checks.
#
# Every data point in every gym computes against one of three public datasets.
# Without them the checks do not fail loudly; they fail in the worst possible
# way, by computing an expected value from nothing. That is the fourth law and
# it was paid for: see README, "The fourth law was paid for".
#
# On a fresh clone `sett rot` will name every path that is missing. This is the
# script that provides them.
#
# It does not just download. For each file it compares what arrived against the
# bytes pinned in MANIFEST.md — the bytes every number in RESULTS.md was
# computed against — and tells you which world you are now in.
#
#   OK     byte-identical to the pin. Your scores are comparable to mine.
#   DRIFT  the feed moved. Your scores are about a different world. That is
#          not a bug and not a failure; it is the reason the hash is pinned.
#
# Two of the three are living feeds and are EXPECTED to drift. CISA revises KEV
# most weekdays; FIRST recomputes every EPSS score daily. Only ATT&CK can be
# pinned, because MITRE publishes immutable numbered releases — so this asks
# for 19.1 by name rather than for whatever "current" means today.
#
# usage: corpus/fetch.sh [DEST]
#        DEST defaults to the location the specs name.
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # corpus/ -> repo root

DEST="${1:-/home/michael/lab/structured-data/raw}"

# name | relative path under DEST | pinned sha256 | source
read -r -d '' SOURCES <<'EOF'
ATT&CK|enterprise-attack-stix21.json|bdf1ce86a4e604214c5076d37ae4dcb322678afc528df8492e6fdc1b554f5da3|https://raw.githubusercontent.com/mitre-attack/attack-stix-data/master/enterprise-attack/enterprise-attack-19.1.json
KEV|kev/known_exploited_vulnerabilities.json|e0326281b91c4f9a5be6bc01b0d0edbbfa933643bc96e5382cd1081b16d8170a|https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
EPSS|epss/epss-hardlinks.json|3aed727a3fcdb7c524c7c131c44aaa898a0441427a377e864ace2154f422f8df|https://api.first.org/data/v1/epss?cve=CVE-2014-6352,CVE-2014-7169,CVE-2015-3113,CVE-2015-5119,CVE-2017-0199,CVE-2017-11774,CVE-2017-11882,CVE-2017-8759,CVE-2021-32648,CVE-2022-0185,CVE-2022-0847,CVE-2022-38028,CVE-2022-42475,CVE-2023-1389,CVE-2023-34362,CVE-2023-46747,CVE-2024-1708,CVE-2024-1709,CVE-2024-20399,CVE-2024-3400,CVE-2024-39717,CVE-2024-55591,CVE-2025-22457,CVE-2025-49704,CVE-2025-49706,CVE-2025-53770
EOF

echo "== corpus -> $DEST =="
echo

fail=0; drift=0
while IFS='|' read -r name rel pin url; do
  [ -n "$name" ] || continue
  out="$DEST/$rel"
  mkdir -p "$(dirname "$out")"

  printf '%-7s ' "$name"
  tmp="$(mktemp)"
  if ! curl -fsSL --retry 2 --max-time 300 -o "$tmp" "$url"; then
    echo "FETCH FAILED  $url"
    rm -f "$tmp"; fail=$((fail+1)); continue
  fi
  # A truncated download is still a file, and a check computing over a
  # truncated corpus is exactly the silent-wrong-answer this repo exists to
  # prevent. Refuse to install anything that is not parseable JSON.
  if ! python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$tmp" 2>/dev/null; then
    echo "NOT JSON      refusing to install a truncated or error-page response"
    rm -f "$tmp"; fail=$((fail+1)); continue
  fi

  got="$(sha256sum "$tmp" | cut -d' ' -f1)"
  mv "$tmp" "$out"; chmod 644 "$out"

  if [ "$got" = "$pin" ]; then
    echo "OK            $(stat -c%s "$out") bytes, byte-identical to the pin"
  else
    echo "DRIFT         $(stat -c%s "$out") bytes"
    echo "        pinned  ${pin:0:16}   (what RESULTS.md was computed against)"
    echo "        got     ${got:0:16}   (what the feed serves today)"
    drift=$((drift+1))
  fi
done <<< "$SOURCES"

echo
if [ "$fail" -gt 0 ]; then
  echo "fetch: $fail source(s) did not arrive. The gyms that read them will not run."
  exit 1
fi
if [ "$drift" -gt 0 ]; then
  echo "fetch: all present, $drift drifted from the pin."
  echo "       Scores you produce now are about today's data, not the data in"
  echo "       RESULTS.md. Re-run a gym before comparing it to a number there."
  echo "       (KEV and EPSS are living feeds. Drift is the expected state.)"
  exit 0
fi
echo "fetch: all present and byte-identical to MANIFEST.md."
