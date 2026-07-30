#!/usr/bin/env bash
# lint — find the operator defects that produce fake model failures.
#
# Three times on 2026-07-30 a point failed because of something MISSING from
# its `do:` that a SIBLING POINT in the same file stated plainly:
#
#   code-sett-8 p2   never named the state.tsv columns; point 1 spells them
#                    out. The model alternated between a correct algorithm
#                    with wrong column indices and correct indices with no
#                    grouping. 0/3 in every configuration tried.
#   code-sett-8 p3/4/7  said "reads a SETT .probe spec" without naming which.
#                    The model went looking, found specs/, and opened its own
#                    answer key. 15 runs did this. Naming the file took p4
#                    from 0/3 to 3/3.
#   code-10 p10      said "a line beginning ## followed by its id"; code-sett-8
#                    p3 says "id is the FIRST token after ##, slug is the
#                    rest". It returned "3 c" where "3" was wanted.
#
# Each cost a real score and read as a model weakness. None were.
#
# This does not judge whether a point is well written. It flags three specific,
# mechanical smells, each one drawn from a defect that actually happened.
#
# usage: ./lint.sh <spec>
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SPEC="${1:?usage: ./lint.sh <spec>}"
F="specs/$SPEC.probe"
[ -f "$F" ] || { echo "no such spec: $F" >&2; exit 2; }

PARSER="reference/code-sett-8-reference"
warn=0

emit() { printf '  %-4s %s\n' "$1" "$2"; warn=$((warn+1)); }

echo "== lint $SPEC =="
echo

# ---------------------------------------------------------------- smell 1
# A point whose CHECK reads a file the DO: never names. The model then has to
# guess or go browsing, and browsing is how it found the answer key.
echo "-- inputs the check reads that the do: never names --"
python3 - "$F" <<'PY'
import re,sys
spec=open(sys.argv[1]).read()
blocks=re.split(r'(?m)^## ',spec)[1:]
for b in blocks:
    pid=b.split(None,1)[0]
    do=""; chk=""
    mode=None
    for line in b.splitlines():
        if line.startswith("do:"):    mode="do";  do  += line[3:]
        elif line.startswith("check:"):mode="chk"; chk += line[6:]
        elif mode=="chk":              chk += "\n"+line
        elif mode=="do":               do  += " "+line
    # absolute paths the CHECK depends on, minus the artifact dir
    cpaths={p for p in re.findall(r'/home/[A-Za-z0-9_./-]+', chk)
            if '/out/' not in p and not p.endswith('/out')}
    dpaths=set(re.findall(r'/home/[A-Za-z0-9_./-]+', do))
    # NOT a defect when the path is a PARAMETER the check supplies: the model
    # is handed it at call time and never needs to know where it lives.
    # e.g. "defining ransomware_count(path) which loads the KEV JSON at `path`"
    if re.search(r'\(\s*path\b|\bat `path`|\bpath is a str', do):
        continue
    missing=sorted(p for p in cpaths if not any(p in d or d in p for d in dpaths))
    if missing:
        print(f"{pid}\tchecks against {missing[0]} — do: names no such path")
PY
echo

# ---------------------------------------------------------------- smell 2
# A point that names a FORMAT which a sibling point describes, but does not
# describe it itself. That asymmetry is exactly what killed p2 and p10.
echo "-- formats a sibling explains but this point does not --"
python3 - "$F" <<'PY'
import re,sys
spec=open(sys.argv[1]).read()
blocks=re.split(r'(?m)^## ',spec)[1:]
pts={}
for b in blocks:
    pid=b.split(None,1)[0]
    do=" ".join(l[3:] if l.startswith("do:") else l
                for l in b.splitlines()
                if l.startswith("do:") or (l.strip() and not l.startswith("check:") and not l.startswith("#")))
    pts[pid]=do
# a "format explanation" = names the artefact type AND enumerates its parts
FORMATS={
 "state.tsv": r"columns|tab-separated columns|timestamp,\s*id",
 ".probe":    r"first token|## |header looks like|id is the",
}
for fmt,expl in FORMATS.items():
    users=[p for p,d in pts.items() if fmt in d]
    explainers=[p for p in users if re.search(expl,pts[p],re.I)]
    silent=[p for p in users if p not in explainers]
    if explainers and silent:
        print(f"{','.join(silent)}\tuses {fmt} but does not describe it; point(s) {','.join(explainers)} do")
PY
echo

# ---------------------------------------------------------------- smell 3
# A check that exercises an edge case (empty input, missing key) the do: never
# mentions. That is how point 6 was marked wrong for a defensible reading.
echo "-- edge cases the check tests that the do: never states --"
python3 - "$F" <<'PY'
import re,sys
spec=open(sys.argv[1]).read()
blocks=re.split(r'(?m)^## ',spec)[1:]
EDGES=[(r'\(\s*\[\s*\]\s*\)|\(\s*\{\s*\}\s*\)|\(""\)',"empty input","empty|no entries|zero"),
       (r'==\s*\[\s*\]|==\s*\{\s*\}',                 "empty result","empty|nothing|no ")]
for b in blocks:
    pid=b.split(None,1)[0]
    do=""; chk=""; mode=None
    for line in b.splitlines():
        if line.startswith("do:"):     mode="do";  do+=line[3:]
        elif line.startswith("check:"):mode="chk"; chk+=line[6:]
        elif mode=="chk":              chk+="\n"+line
        elif mode=="do":               do+=" "+line
    for pat,name,excuse in EDGES:
        if re.search(pat,chk) and not re.search(excuse,do,re.I):
            print(f"{pid}\tcheck exercises {name}; do: never says what it should produce")
            break
PY

echo
echo "(each line is a place the model must GUESS. every guess is a coin flip"
echo " you built, and it will read as a model failure when it lands wrong.)"
