#!/usr/bin/env python3
"""behave — what the model actually DID, from pi's own session transcripts.

Every score in this repo says whether a point passed. None of them says how.
`pi` writes a full transcript per point — every tool call, every thinking
block — to ~/.pi/agent/sessions/**/*.jsonl. That is a record of behaviour, and
behaviour is what the law is trying to change.

SEAT.md rule 1 says "Answer from disk, not from your weights. Before any claim
about a corpus, a file, a model, or a fact — read the file." This measures
whether that instruction is obeyed, rather than assuming it.

Four behaviours per point:

  READ-FIRST  read some input file before writing its artifact
  VERIFY      read its own artifact back after writing it
  EXECUTE     actually ran the thing (bash/python) rather than only writing it
  ONE-SHOT    wrote once, checked nothing

usage: ./behave.py [since]         default: today 19:00
"""
import json, sys, pathlib, collections, re, datetime

SINCE = sys.argv[1] if len(sys.argv) > 1 else "2026-07-30 19:00"
since = datetime.datetime.fromisoformat(SINCE).timestamp()
SESS = pathlib.Path.home() / ".pi/agent/sessions"

def blocks(path):
    for line in path.read_text(errors="ignore").splitlines():
        try: o = json.loads(line)
        except Exception: continue
        if o.get("type") != "message": continue
        m = o.get("message") or o
        c = m.get("content")
        if isinstance(c, list):
            for b in c:
                if isinstance(b, dict):
                    yield m.get("role", "?"), b

rows = []
for f in SESS.rglob("*.jsonl"):
    try:
        if f.stat().st_mtime < since: continue
    except OSError: continue
    gym = re.sub(r".*-out-(.*)--$", r"\1", f.parent.name)
    if gym == f.parent.name: continue          # not a gym run

    task = ""; seq = []
    for role, b in blocks(f):
        t = b.get("type")
        if t == "text" and role == "user" and not task:
            task = b.get("text", "")[:400]
        elif t == "text":
            seq.append(("text", b.get("text", "")))
        elif t == "thinking":
            seq.append(("think", b.get("thinking", "")))
        else:
            seq.append((t or "?", json.dumps(b)[:600]))

    # .txt and .json count too — an earlier version matched only .py|.sh, which
    # forced VERIFY false for every data gym and produced a beautiful, false
    # finding that they never check their work. They write .txt.
    m = re.search(r"out/[^/]+/(\d+)\.(py|sh|txt|json|csv)", task)
    pid = m.group(1) if m else "?"

    blob = " ".join(x[1] for x in seq)
    artifact = m.group(0) if m else None

    # the artifact write is the pivot: everything before it is preparation
    widx = None
    for i, (kind, txt) in enumerate(seq):
        if "Successfully wrote" in txt or "wrote " in txt.lower() and artifact and artifact in txt:
            widx = i; break
    before = " ".join(x[1] for x in seq[:widx]) if widx is not None else ""
    after  = " ".join(x[1] for x in seq[widx:]) if widx is not None else blob

    # Does this task REQUIRE reading anything at write time? A function that
    # takes its input as a parameter does not: the check hands it the path at
    # call time. Counting those as "failed to ground" conflates "did not read"
    # with "had nothing to read", which is how a metric starts lying.
    needs_input = bool(re.search(r"/home/michael/(lab|SETT-repo/fixtures)/", task)) and \
                  not re.search(r"\(\s*path\b|at `path`|taking one argument", task)
    # READ-FIRST: touched a real input path before writing the artifact
    read_first = bool(re.search(r"/home/michael/(lab|SETT-repo/(fixtures|specs))/", before))
    # VERIFY: read its own artifact back afterwards
    verify = bool(artifact and artifact in after and
                  re.search(r"read|cat |Successfully read|def |import |wc |stat ", after))
    # EXECUTE: ran something
    execute = bool(re.search(r"python3 |bash |chmod |\./", after))
    oneshot = not (verify or execute)

    rows.append(dict(gym=gym, pid=pid, read_first=read_first, needs_input=needs_input,
                     verify=verify, execute=execute, oneshot=oneshot,
                     steps=len(seq), ts=f.name[:19]))

if not rows:
    sys.exit("no gym transcripts since " + SINCE)

print(f"== behaviour across {len(rows)} point-runs since {SINCE} ==\n")

def pct(n): return f"{100*n/len(rows):4.0f}%"
agg = collections.Counter()
for r in rows:
    for k in ("read_first", "verify", "execute", "oneshot"):
        agg[k] += bool(r[k])

need = [r for r in rows if r["needs_input"]]
if need:
    rf = sum(r["read_first"] for r in need)
    print(f"  READ-FIRST  {100*rf/len(need):4.0f}%  of the {len(need)} runs that NEEDED to read one")
else:
    print("  READ-FIRST   n/a  no run required reading an input at write time")
print(f"  VERIFY      {pct(agg['verify'])}  read its own artifact back")
print(f"  EXECUTE     {pct(agg['execute'])}  actually ran something")
print(f"  ONE-SHOT    {pct(agg['oneshot'])}  wrote once, checked nothing")
print()

print("-- per gym --")
bygym = collections.defaultdict(list)
for r in rows: bygym[r["gym"]].append(r)
print(f"{'gym':<16}{'runs':<6}{'read-first':<12}{'verify':<9}{'one-shot':<9}{'median steps'}")
for g, rs in sorted(bygym.items()):
    med = sorted(x["steps"] for x in rs)[len(rs)//2]
    rf = sum(x["read_first"] for x in rs); vf = sum(x["verify"] for x in rs)
    os_ = sum(x["oneshot"] for x in rs)
    print(f"{g:<16}{len(rs):<6}{rf}/{len(rs):<9}{vf}/{len(rs):<6}{os_}/{len(rs):<6}{med}")
print()

print("-- points that NEVER read an input, across all their runs --")
byp = collections.defaultdict(list)
for r in rows: byp[(r["gym"], r["pid"])].append(r)
none = [(k, v) for k, v in sorted(byp.items()) if not any(x["read_first"] for x in v)]
for (g, p), v in none:
    print(f"   {g} p{p}  ({len(v)} run(s))")
if not none:
    print("   (none — every point read something at least once)")
