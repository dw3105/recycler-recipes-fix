# Requirement status

One row per clause of `docs/REQUIREMENTS.md`. PASS / FAIL / NOT-TESTED per version. Proof = test full name (`file::describe > it`) or command. Integrator updates at merge.

| ID | 2.0 | 2.1 | Proof |
|---|---|---|---|
| T-1 | PASS | PASS | `make zip` 2026-10-09: `recycler-recipes-fix_0.1.0.zip`, `_0.2.0.zip`; each loads headless on its version, 0 errors |
| T-2 | PASS | PASS | no `control.lua` in tree |
| T-3 | PASS | PASS | lane 002 check `zip-2.0`/`zip-2.1`: hard dep `quality >= 2.0.0` / `recycler >= 2.1.0` |
| T-4 | PASS | n/a | `info.json` 48 `(?)` deps; `make full-check` still runs mod last (same 8 changes) |
| R-1 | PASS | PASS | offline suite loads game file; headless `tests/game/run.sh` PASS with-fix 2.0 and 2.1 (2026-10-09, main a4a3e67) |
| R-2 | PASS | PASS | `test_rebuild.lua::R-2 missing > late recipe gets game-built recycling` |
| R-3 | PASS | PASS | `test_rebuild.lua::R-3 stale > changed source recipe replaces game-built recycling` |
| R-4 | PASS | PASS | `test_rebuild.lua::R-4 still valid > *` (2) |
| R-5 | PASS | PASS | `test_rebuild.lua::R-5 self-recycling > self-recycling replaced when source recipe exists` |
| R-6 | PASS | PASS | `test_rebuild.lua::R-6 hand-made > hand-made recycling untouched after source change` |
| R-7 | PASS | PASS | `test_rebuild.lua::R-7 game-built test > game name with foreign icon counts as hand-made` |
| R-8 | PASS | PASS | `test_rebuild.lua::R-8 rejected source > auto_recycle false keeps current recycling` |
| R-9 | PASS | PASS | `test_rebuild.lua::R-9 unlocks > *` (2) |
| R-10 | PASS | PASS | `tests/game/run.sh` `vanilla-zero` (red on planted always-fix breach, 2026-10-09) |
| S-1 | PASS | PASS | `test_settings.lua::S-1 excluded > *` (3) |
| S-2 | PASS | PASS | `test_settings.lua::S-2 self-recycling switch > *` (3) |
| S-3 | PASS | NOT-TESTED | author play-test 2026-10-09, `SA_D0`, 0.1.0: settings text shown, `big-accumulator` recycles with `magnet`; 2.1 not play-tested |
| L-1 | PASS | PASS | `test_rebuild.lua::L-1 report > log has prefix, counts and per-recipe line` |
| P-1 | PASS | PASS | lane 002 check `zip-2.0`/`zip-2.1` whitelist assert |
| P-2 | PASS | PASS | `thumbnail.png` 144x144 from `tools/make_thumbnail.py`, regen byte-identical |
| P-3 | PASS | PASS | lane 002 check `changelog`: `0.2.0`, `0.1.0` blocks |
| P-4 | PASS | n/a | `make full-check` 2026-10-09 on main a4a3e67: added 2, fixed 5, self 1, excluded 0, `full-check-2.0-ok` |

Owner plants after lane 001 merge (2026-10-09): 8 planted breaches in `scripts/rebuild.lua`, each turned 1-4 owner tests red; restored tree 17/17 green per version.

Release 2026-10-09: GitHub `v0.1.0` (run `Release v0.1.0` success); mod portal `recycler-recipes-fix` owner `dw3105`, category `tweaks`, releases `0.1.0` (2.0), `0.2.0` (2.1).
