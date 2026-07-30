import json,csv,io
def to_csv(path):
    d=json.load(open(path))["vulnerabilities"]
    buf=io.StringIO(); w=csv.writer(buf)
    w.writerow(["cveID","vendorProject","product"])
    for v in d: w.writerow([v.get("cveID",""),v.get("vendorProject",""),v.get("product","")])
    return buf.getvalue()
