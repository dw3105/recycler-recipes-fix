#!/usr/bin/env bash
# Integrator suite: headless --dump-data, planted late recipe changes, with and without the fix mod.
# Usage: tests/game/run.sh <2.0|2.1> <work dir>. Integrator only; lanes never run this.
set -euo pipefail
FV=${1:?fv 2.0|2.1}
F=$HOME/factorio-$FV/factorio
M=$(cd "$(dirname "$0")/../.." && pwd)
W=${2:?work dir}/$FV
[ -n "${LANE_RUN_ID:-}" ] && { echo "tests/game/run.sh: refused under LANE_RUN_ID (integrator only)" >&2; exit 2; }
stage() { # copy mod dir, set factorio_version to FV; on 2.1 hard dep quality -> recycler
  mkdir -p "$2"; cp -r "$1"/info.json "$2"/
  for f in "$1"/*.lua "$1"/scripts "$1"/locale; do [ -e "$f" ] && cp -r "$f" "$2"/; done
  python3 -I -c 'import json,sys; p=sys.argv[1]; d=json.load(open(p)); d["factorio_version"]=sys.argv[2]
d["dependencies"]=[("recycler"+x[7:] if sys.argv[2]=="2.1" and x.startswith("quality") else x) for x in d.get("dependencies",[])]
json.dump(d,open(p,"w"))' "$2/info.json" "$FV"
}
run() { # $1 = name, $2 = with fix (1/0)
  local R=$W/$1; rm -rf "$R"; mkdir -p "$R/mods" "$R/config"
  printf "[path]\nread-data=%s/data\nwrite-data=%s\n" "$F" "$R" > "$R/config/config.ini"
  stage "$M/tests/game/rrf-test" "$R/mods/rrf-test"
  [ "$2" = 1 ] && stage "$M" "$R/mods/recycler-recipes-fix"
  "$F/bin/x64/factorio" --config "$R/config/config.ini" --mod-directory "$R/mods" --dump-data > "$R/stdout.txt" 2>&1
  grep -q "Error" "$R/factorio-current.log" && { grep -m3 Error "$R/factorio-current.log"; return 1; }
  python3 -I - "$R/script-output/data-raw-dump.json" "$2" "$FV" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))["recipe"]
fix = sys.argv[2] == "1"
def names(n): return sorted(e["name"] for e in (r.get(n) or {}).get("results", []))
checks = {
  "rrf-widget-recycling": ["copper-plate", "iron-gear-wheel"] if fix else [],
  "iron-chest-recycling": ["copper-plate"] if fix else ["iron-plate"],
  "steel-chest-recycling": ["stone"],
  "rrf-orphan-recycling": ["rrf-orphan"] if fix else [],
}
bad = [f"{n}: got {names(n)} want {w}" for n, w in checks.items() if names(n) != w]
print(("FAIL " + "; ".join(bad)) if bad else "PASS", "with-fix" if fix else "without-fix", sys.argv[3])
sys.exit(1 if bad else 0)
PY
}
run without 0
run with 1
# R-10: built-in mods only plus this mod -> zero changes.
R=$W/vanilla; rm -rf "$R"; mkdir -p "$R/mods" "$R/config"
printf "[path]\nread-data=%s/data\nwrite-data=%s\n" "$F" "$R" > "$R/config/config.ini"
stage "$M" "$R/mods/recycler-recipes-fix"
"$F/bin/x64/factorio" --config "$R/config/config.ini" --mod-directory "$R/mods" --dump-data > "$R/stdout.txt" 2>&1
n=$(grep -cE "\[recycler-recipes-fix\] (added|fixed|self-recycling added|excluded): 0$" "$R/factorio-current.log" || true)
if [ "$n" = 4 ]; then echo "PASS vanilla-zero $FV"; else grep "\[recycler-recipes-fix\]" "$R/factorio-current.log" | head -5; echo "FAIL vanilla-zero $FV"; exit 1; fi
