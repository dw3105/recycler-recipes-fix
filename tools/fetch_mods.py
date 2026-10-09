#!/usr/bin/env python3
"""Download the mod set named in a Factorio log, newest release per mod for one Factorio version, plus hard deps.

  tools/fetch_mods.py <factorio-current.log> [factorio version, default 2.0] [out dir]
  default out: ~/.cache/recycler-recipes-fix-mods/<version>; writes mod-list.json there.

Mod names come from aai-loaders' "Log mods once" table in the log.
Credentials: ~/.factorio-portal (username=..., token=...), same file sushi-packer's fetch_mods.py uses.
"""
import hashlib, json, os, re, sys, urllib.request

BUILTIN = {"base", "space-age", "quality", "elevated-rails", "core"}
UA = {"User-Agent": "recycler-recipes-fix-fetch/1"}  # default urllib UA gets 403


def mods_from_log(path):
    text = open(path, encoding="utf-8", errors="replace").read()
    block = text.split("Log mods once: {", 1)[1].split("\n}", 1)[0]
    return {a or b for a, b in re.findall(r'^\s*(?:\["([^"]+)"\]|(\S+)) = "', block, re.M)} - BUILTIN


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
        return json.load(r)


def hard_deps(info):
    for d in info.get("dependencies", []):
        d = d.strip()
        if d[:1] in "?!" or d.startswith("(?)"):
            continue
        yield d.lstrip("~+ ").split()[0]


def creds():
    kv = dict(l.strip().split("=", 1) for l in open(os.path.expanduser("~/.factorio-portal")) if "=" in l)
    return kv["username"], kv["token"]


def sha1(p):
    h = hashlib.sha1()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def main(log, fv, out):
    os.makedirs(out, exist_ok=True)
    plan, skipped, todo = {}, [], sorted(mods_from_log(log))
    while todo:
        m = todo.pop()
        if m in plan or m in BUILTIN or m in skipped:
            continue
        rel = [r for r in get("https://mods.factorio.com/api/mods/%s/full" % m)["releases"]
               if r["info_json"]["factorio_version"] == fv]
        if not rel:
            skipped.append(m)
            continue
        plan[m] = max(rel, key=lambda r: r["released_at"])
        todo += list(hard_deps(plan[m]["info_json"]))
    user, token = creds()
    keep = set()
    for m in sorted(plan):
        e = plan[m]
        p = os.path.join(out, e["file_name"])
        keep.add(e["file_name"])
        if os.path.exists(p) and sha1(p) == e["sha1"]:
            continue
        url = "https://mods.factorio.com%s?username=%s&token=%s" % (e["download_url"], user, token)
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=600) as r, open(p + ".part", "wb") as f:
            while b := r.read(1 << 20):
                f.write(b)
        if sha1(p + ".part") != e["sha1"]:
            os.remove(p + ".part")
            raise SystemExit(f"sha1 mismatch {e['file_name']}")
        os.replace(p + ".part", p)
        print("fetched", e["file_name"], os.path.getsize(p))
    for f in os.listdir(out):  # drop other versions so Factorio sees one zip per mod
        if f.endswith(".zip") and f not in keep:
            os.remove(os.path.join(out, f))
    json.dump({"mods": [{"name": n, "enabled": True} for n in sorted(BUILTIN - {"core"}) + sorted(plan)]},
              open(os.path.join(out, "mod-list.json"), "w"), indent=1)
    for m in sorted(plan):
        print("plan", m, plan[m]["version"])
    print(f"ok {len(plan)} mods for {fv} in {out}; no {fv} release: {skipped or 'none'}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    fv = sys.argv[2] if len(sys.argv) > 2 else "2.0"
    main(sys.argv[1], fv, sys.argv[3] if len(sys.argv) > 3 else os.path.expanduser("~/.cache/recycler-recipes-fix-mods/" + fv))
