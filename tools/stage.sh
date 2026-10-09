#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <2.0|2.1> <dest dir>" >&2
  exit 2
fi
fv=$1
dest=$2
case "$fv" in
  2.0|2.1) ;;
  *) echo "unsupported Factorio version: $fv" >&2; exit 2 ;;
esac

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$dest"
cp "$root/info.json" "$root/settings.lua" "$root/data-final-fixes.lua" \
   "$root/changelog.txt" "$root/thumbnail.png" "$root/LICENSE" "$dest/"
cp -R "$root/scripts" "$root/locale" "$dest/"
python3 -I - "$dest/info.json" "$fv" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
fv = sys.argv[2]
data = json.loads(path.read_text())
data['factorio_version'] = fv
if fv == '2.1':
    major, minor, patch = map(int, data['version'].split('.'))
    if (major, minor) != (0, 1):
        raise SystemExit(f"cannot map version {data['version']} to Factorio 2.1")
    data['version'] = f'0.2.{patch}'
    data['dependencies'] = [
        dep.replace('quality >= ', 'recycler >= ').replace('base >= ', 'base >= ')
        for dep in data['dependencies']
    ]
    data['dependencies'] = [
        'base >= 2.1.0' if dep.startswith('base >= ') else
        'recycler >= 2.1.0' if dep.startswith('recycler >= ') else dep
        for dep in data['dependencies']
    ]
path.write_text(json.dumps(data, indent=2) + '\n')
PY
