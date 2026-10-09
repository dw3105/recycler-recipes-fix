# Requirement status

One row per clause of `docs/REQUIREMENTS.md`. PASS / FAIL / NOT-TESTED per version. Proof = test full name (`file::describe > it`) or command. Integrator updates at merge.

| ID | 2.0 | 2.1 | Proof |
|---|---|---|---|
| T-1 | NOT-TESTED | NOT-TESTED | `make zip` (L004) |
| T-2 | PASS | PASS | no `control.lua` in tree |
| T-3 | NOT-TESTED | NOT-TESTED | staged `info.json` (L004) |
| T-4 | NOT-TESTED | NOT-TESTED | `info.json` curated `(?)` list (L004) |
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
| S-3 | NOT-TESTED | NOT-TESTED | `locale/en/locale.cfg` present; headless load no error; in-game display unchecked |
| L-1 | PASS | PASS | `test_rebuild.lua::L-1 report > log has prefix, counts and per-recipe line` |
| P-1 | NOT-TESTED | NOT-TESTED | `make zip` listing (L004) |
| P-2 | NOT-TESTED | NOT-TESTED | `thumbnail.png` 144x144 (L004) |
| P-3 | NOT-TESTED | NOT-TESTED | `changelog.txt` (L004) |
| P-4 | PASS | n/a | `make full-check` 2026-10-09 on main a4a3e67: added 2, fixed 5, self 1, excluded 0, `full-check-2.0-ok` |

Owner plants after lane 001 merge (2026-10-09): 8 planted breaches in `scripts/rebuild.lua`, each turned 1-4 owner tests red; restored tree 17/17 green per version.
