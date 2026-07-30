import json
def group_software(path, group_name):
    o=json.load(open(path))["objects"]; b={x["id"]:x for x in o}
    return sorted({b[r["target_ref"]]["name"] for r in o
        if r["type"]=="relationship" and r["relationship_type"]=="uses"
        and r.get("source_ref") in b and r.get("target_ref") in b
        and b[r["source_ref"]]["type"]=="intrusion-set"
        and b[r["source_ref"]].get("name")==group_name
        and b[r["target_ref"]]["type"] in ("malware","tool")})
