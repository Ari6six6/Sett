import sqlite3
def unmitigated(db_path, phase_name):
    c = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    q = ("select distinct o.name from objects o join kill_chain k on k.object_id=o.id "
         "where o.type='attack-pattern' and k.phase_name=? and o.name is not null "
         "and o.id not in (select target_ref from relationships where relationship_type='mitigates')")
    return sorted(r[0] for r in c.execute(q, (phase_name,)))
