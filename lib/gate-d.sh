#!/usr/bin/env bash
# Gate D — the repair gate.
#
# A repair gym hands the model a broken file and asks for a fixed one. That
# creates a failure mode the other gates cannot see: if the BROKEN input would
# itself pass the check, the point is solvable by copying the input and
# claiming victory. The model would score without repairing anything, and the
# gym would be measuring `cp`.
#
#   gate A  does the check fail with NO artifact?
#   gate B  does it pass the reference implementation?
#   gate C  does it fail a plausible WRONG artifact?
#   gate D  does it fail THE BROKEN INPUT the point hands over?
#
# For every point whose do: names a file under fixtures/broken/, this copies
# that file into a temp out dir as the artifact the point asks for, then runs
# the real check and demands it fail.
#
# usage: ./gate-d.sh <spec>
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root
SPEC="${1:?usage: ./gate-d.sh <spec>}"
F="specs/$SPEC.probe"
[ -f "$F" ] || { echo "no such spec: $F" >&2; exit 2; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

n=0
while IFS=$'\t' read -r pid broken artifact; do
  [ -n "$pid" ] || continue
  [ -f "$broken" ] || { echo "  $pid  MISSING FIXTURE $broken"; continue; }
  cp "$broken" "$TMP/$artifact"
  chmod +x "$TMP/$artifact" 2>/dev/null
  n=$((n+1))
done < <(python3 - "$F" <<'PY'
import re,sys
spec=open(sys.argv[1]).read()
for b in re.split(r'(?m)^## ',spec)[1:]:
    pid=b.split(None,1)[0]
    do=" ".join(l[3:] for l in b.splitlines() if l.startswith("do:"))
    br=re.search(r'(/home/michael/SETT-repo/fixtures/broken/[A-Za-z0-9_.\-]+)',do)
    art=re.search(r'\$OUT/([0-9]+\.[a-z]+)',do)
    if br and art:
        print(f"{pid}\t{br.group(1)}\t{art.group(1)}")
PY
)

if [ "$n" -eq 0 ]; then
  echo "gate D: not a repair gym — no point names a fixtures/broken/ input"
  exit 0
fi

echo "== gate D: $SPEC — the broken inputs must FAIL their own checks =="
echo
out="$(./sett check "$SPEC" --out "$TMP" 2>&1)"
echo "$out" | grep -E '^[0-9]+ ' || true
pass="$(printf '%s' "$out" | grep -cE 'PASS$' || true)"
echo
if [ "${pass:-0}" -gt 0 ]; then
  echo "gate D: $pass point(s) PASS while still broken — those points can be"
  echo "        satisfied by copying the input. They measure cp, not repair."
  exit 1
fi
echo "gate D: 0/$n broken inputs pass. Every point requires an actual repair."
