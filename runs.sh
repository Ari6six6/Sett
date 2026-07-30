#!/usr/bin/env bash
# runs — fly one gym n times, keeping EVERY rep's artifacts.
#
# `sett gym` writes into out/<spec>, so a second run destroys the first. That
# cost real evidence on 2026-07-30: code-10 points 8 and 9 failed in reps 1
# and 2, and by the time the numbers were in, only rep 3 was on disk and both
# points had passed in it. The failures were unexaminable.
#
# usage: ./runs.sh <spec> <n> [law]
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SPEC="${1:?usage: ./runs.sh <spec> <n> [law]}"; N="${2:?}"; LAW="${3:-}"
TSV="runs/ab-$SPEC-x$N.tsv"; : > "$TSV"
mkdir -p runs/archive
for r in $(seq 1 "$N"); do
  rm -rf "out/$SPEC" "runs/$SPEC"
  args=(gym "$SPEC"); [ -n "$LAW" ] && args+=(--law "$LAW")
  SETT_TIMEOUT="${SETT_TIMEOUT:-420}" ./sett "${args[@]}" > "runs/archive/$SPEC-rep$r.log" 2>&1
  awk -F'\t' -v r="$r" '{v[$2]=$3} END {for (k in v) print "R\t" r "\t" k "\t" v[k]}' \
      "runs/$SPEC/state.tsv" >> "$TSV"
  # keep this rep's artifacts BEFORE the next one wipes them
  cp -r "out/$SPEC" "runs/archive/$SPEC-rep$r" 2>/dev/null
  rm -rf "runs/archive/$SPEC-rep$r/__pycache__"
  echo "rep $r: $(awk -F'\t' '{v[$2]=$3} END {n=0;for(k in v) if(v[k]=="PASS") n++; print n}' "runs/$SPEC/state.tsv") PASS   -> runs/archive/$SPEC-rep$r/"
done
echo
./ab-analyse.py "$SPEC-x$N" 2>/dev/null || echo "raw: $TSV"
