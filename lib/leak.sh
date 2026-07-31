#!/usr/bin/env bash
# leak — did a run read the file containing its own answers?
#
# The gym's central claim is: "The model receives `do:` and never `check:` — a
# model that can read the gate can teach to it."
#
# That claim was false. The model has a bash tool, and specs/<name>.probe is
# world-readable at a predictable path with every check in it. Worse, three
# points of code-sett-8 (points 3, 4, 7) and one of code-10 (point 10) REQUIRE
# a .probe file to parse. The tasks send the model looking for sample specs,
# and the nearest sample is the answer key.
#
# Audited on 2026-07-30: specs/code-10.probe was read 20 times and
# specs/code-sett-8.probe 10 times across the day's runs. One transcript shows
# the model reasoning "Each point has a `do:` line and optionally a `check:`
# line" — it had the file open. Point 4's check states its expected values
# outright (5/12, 1/3).
#
# No artifact was found to hardcode an expected value: the leak was available
# and not taken. That is luck, not design, and luck is what this repo exists
# to stop relying on.
#
# pi writes full session transcripts to ~/.pi/agent/sessions/**/*.jsonl,
# including tool calls and thinking. This reads them.
#
# usage: ./leak.sh [since]        default: today
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root

SINCE="${1:-$(date +%Y-%m-%d) 00:00}"
SESS="$HOME/.pi/agent/sessions"
[ -d "$SESS" ] || { echo "no pi sessions at $SESS"; exit 0; }

echo "== self-spec reads since $SINCE =="
echo

found=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  # which gym was this run working in? pi's cwd is the gym's out dir, which
  # pi encodes into the session directory name: --home-michael-...-out-<gym>--
  gym="$(basename "$(dirname "$f")" | sed -n 's/.*-out-\(.*\)--$/\1/p')"
  [ -n "$gym" ] || continue

  # did it touch that gym's OWN spec?
  if grep -q "specs/$gym.probe" "$f" 2>/dev/null; then
    # The point under work is the one named in the TASK PROMPT, not every file
    # the model happened to see. A model that runs `ls` on its out dir mentions
    # every artifact there, which made the first version of this report wrong.
    pts="$(head -5 "$f" | grep -oE "Write (a Python file|an executable bash script) [^ ]*out/$gym/[0-9]+\.(py|sh)" | grep -oE '[0-9]+\.(py|sh)' | grep -oE '^[0-9]+' | sort -un | tr '\n' ' ')"
    ts="$(basename "$f" | cut -c1-19)"
    echo "  LEAK  $ts  gym=$gym  points: ${pts:-?}"
    found=$((found+1))
  fi
done < <(find "$SESS" -name '*.jsonl' -newermt "$SINCE" 2>/dev/null)

echo
if [ "$found" -eq 0 ]; then
  echo "clean: no run read its own spec"
  exit 0
fi

echo "$found run(s) read the spec containing their own checks."
echo
echo "This does not prove the score is wrong — check whether the artifact"
echo "computes its answer or hardcodes it. It proves the score is UNPROVEN,"
echo "which for this repo is the same thing."
exit 1
