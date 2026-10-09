#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "usage: $0 <2.0|2.1>" >&2
  exit 2
fi
fv=$1
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
case "$fv" in
  2.0) version=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$root/info.json") ;;
  2.1)
    version=$(python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); a,b,c=map(int,d["version"].split(".")); assert (a,b)==(0,1); print(f"0.2.{c}")' "$root/info.json")
    ;;
  *) echo "unsupported Factorio version: $fv" >&2; exit 2 ;;
esac
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
"$root/tools/stage.sh" "$fv" "$tmp/stage"
mkdir -p "$root/build"
python3 -I - "$tmp/stage" "$root/build/recycler-recipes-fix_${version}.zip" "$version" <<'PY'
from pathlib import Path
import sys
import zipfile

stage = Path(sys.argv[1])
out = Path(sys.argv[2])
prefix = f"recycler-recipes-fix_{sys.argv[3]}"
with zipfile.ZipFile(out, 'w', compression=zipfile.ZIP_DEFLATED) as zf:
    for path in sorted(stage.rglob('*')):
        if path.is_file():
            zf.write(path, (Path(prefix) / path.relative_to(stage)).as_posix())
PY
printf '%s\n' "$root/build/recycler-recipes-fix_${version}.zip"
