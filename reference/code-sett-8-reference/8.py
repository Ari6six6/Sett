def scaffold(name, outdir, questions):
    L=[f"# spec: {name}", f"# out:  {outdir}", ""]
    for i,q in enumerate(questions,1):
        L.append(f"## {i} {q['slug']}")
        L.append(f"do:    {q['do']}")
        L.append(f"check: {q['check']}")
        L.append("")
    return "\n".join(L)
