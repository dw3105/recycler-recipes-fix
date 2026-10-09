#!/usr/bin/env bash
# P-4: headless --dump-data with the fetched mod set (~/.cache/recycler-recipes-fix-mods/<FV>) plus this mod.
# Usage: tests/game/full_check.sh <FV> <work dir>. Integrator only. Prints the mod's log lines; exit 1 on any Error.
set -euo pipefail
FV=${1:?fv}; F=$HOME/factorio-$FV/factorio; M=$(cd "$(dirname "$0")/../.." && pwd)
C=$HOME/.cache/recycler-recipes-fix-mods/$FV; R=${2:?work dir}/full-$FV
[ -n "${LANE_RUN_ID:-}" ] && { echo "full_check.sh: refused under LANE_RUN_ID (integrator only)" >&2; exit 2; }
rm -rf "$R"; mkdir -p "$R/mods" "$R/config"
printf "[path]\nread-data=%s/data\nwrite-data=%s\n" "$F" "$R" > "$R/config/config.ini"
for z in "$C"/*.zip; do ln -s "$z" "$R/mods/"; done
mkdir -p "$R/mods/recycler-recipes-fix"
cp -r "$M"/info.json "$M"/*.lua "$R/mods/recycler-recipes-fix/"
for d in scripts locale; do [ -d "$M/$d" ] && cp -r "$M/$d" "$R/mods/recycler-recipes-fix/"; done
python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); d["mods"].append({"name":"recycler-recipes-fix","enabled":True}); json.dump(d,open(sys.argv[2],"w"))' "$C/mod-list.json" "$R/mods/mod-list.json"
"$F/bin/x64/factorio" --config "$R/config/config.ini" --mod-directory "$R/mods" --dump-data > "$R/stdout.txt" 2>&1 || true
grep "\[recycler-recipes-fix\]" "$R/factorio-current.log" | sed 's/.*\[recycler-recipes-fix\]/[recycler-recipes-fix]/'
if grep -q " Error " "$R/factorio-current.log"; then grep -m3 " Error " "$R/factorio-current.log"; echo "full-check-$FV FAIL"; exit 1; fi
echo "full-check-$FV-ok"
