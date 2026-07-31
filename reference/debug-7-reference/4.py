def grounded_ratio(path):
    total=0; grounded=0; cur=False; seen=False
    for line in open(path):
        if line.startswith("## "):
            total+=1; seen=True
        elif line.startswith("do:") and seen:
            if "/home/" in line: grounded+=1
    return grounded/total if total else 0.0
