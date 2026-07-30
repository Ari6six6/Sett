def flatten(d, sep="."):
    out={}
    def walk(cur, prefix):
        for k,v in cur.items():
            key=f"{prefix}{sep}{k}" if prefix else str(k)
            if isinstance(v,dict): walk(v,key)
            else: out[key]=v
    walk(d,""); return out
