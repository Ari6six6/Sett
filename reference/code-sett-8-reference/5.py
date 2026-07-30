import hashlib,os
def verify(manifest_path):
    bad=[]
    for line in open(manifest_path):
        line=line.rstrip("\n")
        if not line.strip(): continue
        digest,_,path=line.partition("  ")
        if not path: continue
        if not os.path.isfile(path): bad.append(path); continue
        h=hashlib.sha256()
        with open(path,"rb") as f:
            for chunk in iter(lambda: f.read(65536), b""): h.update(chunk)
        if h.hexdigest()!=digest: bad.append(path)
    return bad
