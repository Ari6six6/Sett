#!/usr/bin/env bash
# ab — run one gym n times under each of two laws, and report every point.
#
# Written because the first law A/B came back 6/8 vs 4/8 with FOUR of eight
# points flipping in both directions. At n=1 per arm that is indistinguishable
# from noise, and the diagnosis confirmed it: the newly-failing points died on
# `path.read_text()` against a str and on two unrelated parser bugs — nothing
# any law could have caused.
#
# One run of a gym is an anecdote. This makes it a measurement.
#
# usage: ./ab.sh <spec> <n> <lawA> <lawB>
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root

SPEC="${1:?usage: ./ab.sh <spec> <n> <lawA> <lawB>}"
N="${2:?}"; LAW_A="${3:?}"; LAW_B="${4:?}"
LOG="runs/ab-$SPEC.tsv"
mkdir -p runs
: > "$LOG"

run_one() {                       # arm  rep  lawfile
  local arm="$1" rep="$2" law="$3"
  # Archive the PREVIOUS rep before destroying it. Without this only the last
  # rep survives, and on 2026-07-30 that made two of three failing points
  # impossible to diagnose after the box was already down. A failure you
  # cannot open is a failure you cannot learn from.
  if [ -d "out/$SPEC" ]; then
    local prev="runs/archive/$SPEC-$(date +%H%M%S)-prev"
    mkdir -p "$(dirname "$prev")" && cp -r "out/$SPEC" "$prev" 2>/dev/null
    rm -rf "$prev/__pycache__"
  fi
  rm -rf "out/$SPEC" "runs/$SPEC"
  local args=(gym "$SPEC")
  [ "$law" != "-" ] && args+=(--law "$law")
  SETT_TIMEOUT=420 ./sett "${args[@]}" > "/tmp/ab-$SPEC-$arm-$rep.log" 2>&1
  # one row per point, so the analysis can be per-point and not just per-run
  awk -F'\t' -v a="$arm" -v r="$rep" '{v[$2]=$3} END {for (k in v) print a "\t" r "\t" k "\t" v[k]}' \
      "runs/$SPEC/state.tsv" >> "$LOG"
  local p; p="$(awk -F'\t' '{v[$2]=$3} END {n=0;for(k in v) if(v[k]=="PASS") n++; print n}' "runs/$SPEC/state.tsv")"
  echo "  $arm rep $rep: $p PASS"
}

echo "A = $LAW_A"
echo "B = $LAW_B"
echo
for r in $(seq 1 "$N"); do
  run_one A "$r" "$LAW_A"
  run_one B "$r" "$LAW_B"
done

echo
echo "=== per-run totals ==="
awk -F'\t' '$4=="PASS" {c[$1"\t"$2]++} END {for (k in c) print k "\t" c[k]}' "$LOG" | sort

echo
echo "=== per-point pass rate (out of $N) ==="
printf '%-4s %-6s %-6s\n' id A B
awk -F'\t' -v n="$N" '
  {seen[$3]=1; if ($4=="PASS") p[$1"_"$3]++}
  END {for (id in seen) printf "%-4s %-6s %-6s\n", id, (p["A_"id]+0)"/"n, (p["B_"id]+0)"/"n}
' "$LOG" | sort -V

echo
echo "=== totals ==="
awk -F'\t' -v n="$N" '
  $4=="PASS" {t[$1]++}
  END {printf "A: %d/%d points\nB: %d/%d points\n", t["A"]+0, n*8, t["B"]+0, n*8}
' "$LOG"
echo
echo "raw: $LOG"
