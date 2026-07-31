import sqlite3
def phase_techniques(db_path, phase_name):
    c = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    q = ("select distinct o.name from objects o join kill_chain k on k.object_id=o.id "
         "where o.type='attack-pattern' and k.phase_name=? and o.name is not null")
    return sorted(r[0] for r in c.execute(q, (phase_name,)))
