def checks(path):
    out={}; cur=None; buf=None
    for line in open(path):
        s=line.rstrip("\n")
        if s.startswith("## "):
            if cur and buf is not None: out[cur]="\n".join(buf).strip()
            cur=s[3:].strip().split()[0]; buf=None
        elif s.startswith("check:"):
            buf=[s[len("check:"):].strip()]
        elif buf is not None:
            if not s.strip(): 
                out[cur]="\n".join(buf).strip(); buf=None
            elif s.startswith("do:"): 
                out[cur]="\n".join(buf).strip(); buf=None
            else: buf.append(s)
    if cur and buf is not None: out[cur]="\n".join(buf).strip()
    return out
