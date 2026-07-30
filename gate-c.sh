#!/usr/bin/env bash
# Gate C — the wrong-but-present gate.
#
# `sett gate` runs each check against an EMPTY out dir and demands it fail.
# That catches "a file appeared" checks. It does NOT catch the subtler fake:
# a check that imports the artifact, never exercises it, and passes against a
# stub that has the right SHAPE and the wrong BEHAVIOUR.
#
# This script plants exactly that stub and demands the check still fail.
# For every artifact the spec names ($OUT/N.py, $OUT/N.sh, $OUT/N.json, ...)
# it writes a plausible-looking impostor:
#   .py   — every function named in the do: line, defined, returning junk
#   .sh   — executable, exits 0, prints plausible-looking output
#   .json — valid JSON of the wrong value
#   .txt  — a number, wrong
#
# A check that passes against this is not measuring behaviour. It is measuring
# that someone showed up.
#
# usage: ./gate-c.sh <spec>
set -uo pipefail

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SPEC="${1:?usage: ./gate-c.sh <spec>}"
F="specs/$SPEC.probe"
[ -f "$F" ] || { echo "no such spec: $F" >&2; exit 2; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Reuse the spec parser the dogfood gym produced. This is the tool being used,
# not just scored.
PARSER="reference/code-sett-8-reference"

mapfile -t IDS < <(python3 -c '
import importlib.util,sys
s=importlib.util.spec_from_file_location("m",sys.argv[1]+"/3.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
for i,_ in m.points(sys.argv[2]): print(i)
' "$PARSER" "$F")

total=0; real=0; fake=0

for id in "${IDS[@]}"; do
  [ -n "$id" ] || continue
  total=$((total+1))

  out="$TMP/$id"; rm -rf "$out"; mkdir -p "$out"

  # --- plant the impostor -------------------------------------------------
  # Names of artifacts and functions come from the do: line of this point.
  python3 - "$F" "$id" "$out" <<'PY'
import re,sys,json,os,stat
spec,pid,out = sys.argv[1],sys.argv[2],sys.argv[3]
txt = open(spec).read()
# isolate this point's block
blocks = re.split(r'(?m)^## ', txt)
blk = next((b for b in blocks if b.split(None,1)[0:1] == [pid]), "")
do = ""
for line in blk.splitlines():
    if line.startswith("do:"): do = line[3:].strip()

# every $OUT/<name> the do: line names
arts = re.findall(r'\$OUT/([A-Za-z0-9_.\-]+)', do)
# every identifier used as a call target, e.g. "defining dedupe(items)"
fns = re.findall(r'([a-z_][a-z0-9_]*)\s*\(', do)
fns = [f for f in fns if f not in ("e","g")] or ["main"]

for a in arts:
    p = os.path.join(out, a)
    if a.endswith(".py"):
        body = ["# impostor: right shape, wrong behaviour"]
        for f in sorted(set(fns)):
            body.append(f"def {f}(*a, **k):\n    return []")
        open(p,"w").write("\n".join(body) + "\n")
    elif a.endswith(".sh"):
        open(p,"w").write("#!/usr/bin/env bash\necho 'total: 0'\necho 'ransomware: 0'\nexit 0\n")
        os.chmod(p, os.stat(p).st_mode | stat.S_IEXEC)
    elif a.endswith(".json"):
        open(p,"w").write(json.dumps(["wrong","wrong","wrong"]))
    else:
        open(p,"w").write("0\n")
PY

  # --- run the real check against the impostor ----------------------------
  chk="$(python3 -c '
import importlib.util,sys
s=importlib.util.spec_from_file_location("m",sys.argv[1]+"/7.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
print(m.checks(sys.argv[2]).get(sys.argv[3],""))
' "$PARSER" "$F" "$id")"

  printf '%-5s ' "$id"
  if [ -z "$chk" ]; then
    echo "NO CHECK"; fake=$((fake+1)); continue
  fi

  if OUT="$out" timeout 60 bash -c "$chk" >/dev/null 2>&1; then
    echo "FAKE — passes on a wrong-but-present artifact"
    fake=$((fake+1))
  else
    echo "ok (rejects wrong-but-present)"
    real=$((real+1))
  fi
done

echo
echo "gate C: $real/$total checks reject a plausible impostor, $fake FAKE"
[ "$fake" -eq 0 ]
