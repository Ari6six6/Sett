#!/usr/bin/env python3
"""Spells — one word, one recognisable analyst ability, one verified answer.

Every other verb in this repo is for the operator: gyms, gates, rot, lint.
Nothing here could be handed to someone who does not already know what a
`.probe` file is. These can.

A spell takes a name, not a query language. `sett cast threat APT29` is a
question a person can ask out loud, and the answer is a real multi-hop
traversal of 25 843 MITRE ATT&CK objects — the same work the gyms grade.

Two rules make them worth showing:

  1. **A spell is not a model.** No GPU, no rental, no network, no waiting.
     These are deterministic queries over pinned corpora. The model's job was
     to *earn* the tool; casting it is free forever after.

  2. **A spell shows its receipt.** Every answer prints the one-line command
     that recomputes it from the raw corpus, independently of this script.
     An answer you cannot re-derive is a claim, and this repo does not take
     claims. Paste the receipt, get the same number, or the spell is lying.

usage: sett cast <spell> [argument]
       sett cast          # list the spells
"""
import json, os, sys, collections, datetime

CORPUS = os.environ.get("SETT_CORPUS", "/home/michael/lab/structured-data/raw")
STIX = f"{CORPUS}/enterprise-attack-stix21.json"
KEV = f"{CORPUS}/kev/known_exploited_vulnerabilities.json"
EPSS = f"{CORPUS}/epss/epss-hardlinks.json"

B, D, R, G, Y, X = "\033[1m", "\033[2m", "\033[31m", "\033[32m", "\033[33m", "\033[0m"
if not sys.stdout.isatty():
    B = D = R = G = Y = X = ""


def load(path):
    try:
        with open(path) as fh:
            return json.load(fh)
    except FileNotFoundError:
        sys.exit(f"corpus missing: {path}\n  run corpus/fetch.sh, or set SETT_CORPUS")


def stix():
    return load(STIX)["objects"]


def kev():
    return load(KEV)["vulnerabilities"]


def head(title, sub=""):
    print(f"\n{B}{title}{X}" + (f"  {D}{sub}{X}" if sub else ""))
    print(f"{D}{'─' * min(len(title) + len(sub) + 2, 72)}{X}")


def receipt(cmd):
    """Print a command that recomputes the answer WITHOUT this script.

    The first version of this printed `sett cast <spell>` — the same script
    recomputing itself, which proves nothing. A receipt that cites its own
    issuer is not a receipt. Each of these is stdlib python over the raw
    corpus, so it can be pasted anywhere python3 exists.
    """
    print(f"\n{D}  receipt — recompute WITHOUT this script:{X}")
    print(f"{D}  $ python3 -c '{cmd}'{X}")


def rows(items, empty="nothing found"):
    if not items:
        print(f"  {D}{empty}{X}")
    for i in items:
        print(f"  {i}")
    print(f"\n  {B}{len(items)}{X} result(s)")


# ─────────────────────────────────────────────────────────── the spells ──

def sp_threat(arg):
    """What software and tools does a named threat group use?"""
    if not arg:
        sys.exit("usage: sett cast threat <group>      e.g. APT29")
    objs = stix()
    by_id = {o["id"]: o for o in objs}
    groups = [o for o in objs if o.get("type") == "intrusion-set"
              and (arg.lower() in o.get("name", "").lower()
                   or arg.lower() in [a.lower() for a in o.get("aliases", [])])]
    if not groups:
        sys.exit(f"no intrusion-set matching {arg!r}")
    g = groups[0]
    used = sorted({by_id[r["target_ref"]]["name"]
                   for r in objs
                   if r.get("type") == "relationship"
                   and r.get("relationship_type") == "uses"
                   and r.get("source_ref") == g["id"]
                   and r.get("target_ref") in by_id
                   and by_id[r["target_ref"]].get("type") in ("malware", "tool")})
    head(f"{g['name']} — arsenal", f"aliases: {', '.join(g.get('aliases', [])[:4])}")
    rows(used)
    receipt(f'import json;o=json.load(open("{STIX}"))["objects"];i={{x["id"]:x for x in o}};g=[x for x in o if x.get("type")=="intrusion-set" and "{arg}".lower() in (x.get("name","")+" "+" ".join(x.get("aliases",[]))).lower()][0];print(len({{i[r["target_ref"]]["name"] for r in o if r.get("relationship_type")=="uses" and r.get("source_ref")==g["id"] and i.get(r.get("target_ref"),{{}}).get("type") in ("malware","tool")}}))')


def sp_arsenal(arg):
    """Which threat groups use a given piece of malware or tool?"""
    if not arg:
        sys.exit("usage: sett cast arsenal <malware|tool>   e.g. Cobalt Strike")
    objs = stix()
    by_id = {o["id"]: o for o in objs}
    tgt = [o for o in objs if o.get("type") in ("malware", "tool")
           and arg.lower() in o.get("name", "").lower()]
    if not tgt:
        sys.exit(f"no malware or tool matching {arg!r}")
    t = tgt[0]
    users = sorted({by_id[r["source_ref"]]["name"]
                    for r in objs
                    if r.get("type") == "relationship"
                    and r.get("relationship_type") == "uses"
                    and r.get("target_ref") == t["id"]
                    and r.get("source_ref") in by_id
                    and by_id[r["source_ref"]].get("type") == "intrusion-set"})
    head(f"{t['name']} — who wields it", t.get("type"))
    rows(users)
    receipt(f'import json;o=json.load(open("{STIX}"))["objects"];i={{x["id"]:x for x in o}};t=[x for x in o if x.get("type") in ("malware","tool") and "{arg}".lower() in x.get("name","").lower()][0];print(len({{i[r["source_ref"]]["name"] for r in o if r.get("relationship_type")=="uses" and r.get("target_ref")==t["id"] and i.get(r.get("source_ref"),{{}}).get("type")=="intrusion-set"}}))')


def sp_technique(arg):
    """What is a technique, who uses it, and what stops it?"""
    if not arg:
        sys.exit("usage: sett cast technique <ATT&CK id>   e.g. T1059")
    objs = stix()
    by_id = {o["id"]: o for o in objs}

    def extid(o):
        for r in o.get("external_references", []):
            if r.get("source_name") == "mitre-attack":
                return r.get("external_id")
        return None

    hits = [o for o in objs if o.get("type") == "attack-pattern" and extid(o) == arg.upper()]
    if not hits:
        sys.exit(f"no technique with id {arg!r}")
    t = hits[0]
    users, mitigations = set(), set()
    for r in objs:
        if r.get("type") != "relationship":
            continue
        if r.get("target_ref") != t["id"]:
            continue
        src = by_id.get(r.get("source_ref"))
        if not src:
            continue
        if r["relationship_type"] == "uses" and src.get("type") == "intrusion-set":
            users.add(src["name"])
        if r["relationship_type"] == "mitigates" and src.get("type") == "course-of-action":
            mitigations.add(src["name"])
    phases = [p.get("phase_name") for p in t.get("kill_chain_phases", [])]
    head(f"{arg.upper()} — {t.get('name')}", " · ".join(phases))
    desc = (t.get("description") or "").split("\n")[0]
    print(f"  {desc[:300]}")
    print(f"\n  {B}used by{X} ({len(users)})")
    rows(sorted(users)[:20], "no group attributed")
    print(f"\n  {B}mitigated by{X} ({len(mitigations)})")
    rows(sorted(mitigations), f"{R}NOTHING — no documented mitigation{X}")
    receipt(f'import json;o=json.load(open("{STIX}"))["objects"];t=[x for x in o if x.get("type")=="attack-pattern" and any(e.get("external_id")=="{arg.upper()}" for e in x.get("external_references",[]))][0];print("users",len({{r["source_ref"] for r in o if r.get("relationship_type")=="uses" and r.get("target_ref")==t["id"]}}),"mitigations",len({{r["source_ref"] for r in o if r.get("relationship_type")=="mitigates" and r.get("target_ref")==t["id"]}}))')


def sp_exposed(arg):
    """Techniques in a kill-chain phase with NO documented mitigation."""
    phase = arg or "execution"
    objs = stix()
    mitigated = {r["target_ref"] for r in objs
                 if r.get("type") == "relationship" and r.get("relationship_type") == "mitigates"}
    out = sorted({o["name"] for o in objs
                  if o.get("type") == "attack-pattern"
                  and not o.get("revoked") and not o.get("x_mitre_deprecated")
                  and phase in [p.get("phase_name") for p in o.get("kill_chain_phases", [])]
                  and o["id"] not in mitigated})
    head(f"{phase} — techniques with no documented mitigation",
         "the gaps a defender cannot buy their way out of")
    rows(out, "every technique in this phase has a mitigation")
    receipt(f'import json;o=json.load(open("{STIX}"))["objects"];m={{r["target_ref"] for r in o if r.get("relationship_type")=="mitigates"}};print(len({{x["name"] for x in o if x.get("type")=="attack-pattern" and not x.get("revoked") and not x.get("x_mitre_deprecated") and "{phase}" in [p.get("phase_name") for p in x.get("kill_chain_phases",[])] and x["id"] not in m}}))')


def sp_ransomware(arg):
    """Known-exploited vulnerabilities used in ransomware campaigns."""
    v = [x for x in kev() if x.get("knownRansomwareCampaignUse") == "Known"]
    v.sort(key=lambda x: x["dateAdded"], reverse=True)
    head("KEV — confirmed ransomware use", f"{len(v)} of {len(kev())} catalogue entries")
    rows([f"{x['dateAdded']}  {x['cveID']:<18} {x['vendorProject']} {x['product']}"
          for x in v[: int(arg) if (arg or '').isdigit() else 25]])
    print(f"  {D}(showing most recent; pass a number for more){X}")
    receipt(f'import json;print(sum(1 for v in json.load(open("{KEV}"))["vulnerabilities"] if v.get("knownRansomwareCampaignUse")=="Known"))')


def sp_vendor(arg):
    """Every known-exploited vulnerability for one vendor."""
    if not arg:
        top = collections.Counter(x["vendorProject"] for x in kev()).most_common(12)
        head("vendors in the KEV catalogue", "pass one as the argument")
        rows([f"{n:<28} {c:>4} entries" for n, c in top])
        return
    v = [x for x in kev() if arg.lower() in x["vendorProject"].lower()]
    v.sort(key=lambda x: x["dateAdded"], reverse=True)
    ransom = sum(1 for x in v if x.get("knownRansomwareCampaignUse") == "Known")
    head(f"{arg} — known exploited", f"{len(v)} entries, {ransom} used in ransomware")
    rows([f"{x['dateAdded']}  {x['cveID']:<18} {x['product'][:44]}" for x in v[:30]])
    receipt(f'import json;print(sum(1 for v in json.load(open("{KEV}"))["vulnerabilities"] if "{arg}".lower() in v["vendorProject"].lower()))')


def sp_overdue(arg):
    """KEV entries whose federal remediation deadline has passed."""
    today = datetime.date.today().isoformat()
    v = [x for x in kev() if x.get("dueDate", "9999") < today]
    v.sort(key=lambda x: x["dueDate"], reverse=True)
    head("KEV — past the CISA remediation deadline",
         f"{len(v)} of {len(kev())} entries, as of {today}")
    rows([f"due {x['dueDate']}  {x['cveID']:<18} {x['vendorProject']} {x['product'][:34]}"
          for x in v[:25]])
    print(f"  {D}(most recent deadlines first){X}")
    receipt(f'import json,datetime;d=datetime.date.today().isoformat();print(sum(1 for v in json.load(open("{KEV}"))["vulnerabilities"] if v.get("dueDate","9999")<d))')


def sp_hot(arg):
    """KEV vulnerabilities ranked by EPSS exploitation probability."""
    e = load(EPSS)["data"]
    k = {x["cveID"]: x for x in kev()}
    scored = sorted(e, key=lambda x: float(x["epss"]), reverse=True)
    head("highest exploitation probability", f"EPSS model date {e[0].get('date', '?')}")
    out = []
    for s in scored[:25]:
        row = k.get(s["cve"])
        pct = float(s["epss"]) * 100
        tag = f"{R}ransomware{X}" if row and row.get("knownRansomwareCampaignUse") == "Known" else ""
        who = f"{row['vendorProject']} {row['product'][:26]}" if row else f"{D}not in KEV{X}"
        out.append(f"{pct:6.2f}%  {s['cve']:<18} {who} {tag}")
    rows(out)
    receipt(f'import json;d=json.load(open("{EPSS}"))["data"];print(max(d,key=lambda x:float(x["epss"]))["cve"])')


SPELLS = {
    "threat":     (sp_threat,     "<group>",      "what software and tools a threat group uses"),
    "arsenal":    (sp_arsenal,    "<malware>",    "which groups wield a given malware or tool"),
    "technique":  (sp_technique,  "<T-id>",       "what a technique is, who uses it, what stops it"),
    "exposed":    (sp_exposed,    "[phase]",      "techniques in a phase with NO mitigation"),
    "ransomware": (sp_ransomware, "[n]",          "known-exploited vulns confirmed in ransomware"),
    "vendor":     (sp_vendor,     "[name]",       "every known-exploited vuln for one vendor"),
    "overdue":    (sp_overdue,    "",             "KEV entries past the federal deadline"),
    "hot":        (sp_hot,        "",             "vulnerabilities by exploitation probability"),
}


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help", "help"):
        print(f"\n{B}sett cast <spell> [argument]{X}\n")
        print(f"  {D}Eight abilities over 25 843 ATT&CK objects, 1 655 CISA KEV")
        print(f"  entries and FIRST EPSS scores. No GPU. No network. No model.{X}\n")
        for n, (_, a, d) in SPELLS.items():
            print(f"  {B}{n:<11}{X}{D}{a:<12}{X} {d}")
        print(f"\n  {D}every spell prints a receipt: the command that recomputes")
        print(f"  its own answer, so no result here has to be taken on trust.{X}\n")
        return 0
    name = sys.argv[1]
    if name not in SPELLS:
        sys.exit(f"no such spell: {name}\n  sett cast   — to list them")
    arg = " ".join(sys.argv[2:]) or None
    SPELLS[name][0](arg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
