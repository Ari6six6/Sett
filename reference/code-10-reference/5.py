import json
def ransomware_count(path):
    d=json.load(open(path))
    return sum(1 for v in d["vulnerabilities"] if v.get("knownRansomwareCampaignUse")=="Known")
