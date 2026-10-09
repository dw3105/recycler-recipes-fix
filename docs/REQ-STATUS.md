# Requirement status

One row per clause of `docs/REQUIREMENTS.md`. PASS / FAIL / NOT-TESTED per version. Proof = test full name (`file::describe > it`) or command. Integrator updates at merge.

| ID | 2.0 | 2.1 | Proof |
|---|---|---|---|
| T-1 | NOT-TESTED | NOT-TESTED | `make zip` (L004) |
| T-2 | PASS | PASS | no `control.lua` in tree |
| T-3 | NOT-TESTED | NOT-TESTED | staged `info.json` (L004) |
| T-4 | NOT-TESTED | NOT-TESTED | `info.json` curated `(?)` list (L004) |
| R-1 | FAIL | FAIL | offline suite loads game file; 2.1 headless: `module __quality__.prototypes.recycling not found` |
| R-2 | FAIL | FAIL | `test_rebuild.lua::R-2 missing > late recipe gets game-built recycling` |
| R-3 | FAIL | FAIL | `test_rebuild.lua::R-3 stale > changed source recipe replaces game-built recycling` |
| R-4 | FAIL | FAIL | `test_rebuild.lua::R-4 still valid > *` (2) |
| R-5 | FAIL | FAIL | `test_rebuild.lua::R-5 self-recycling > self-recycling replaced when source recipe exists` |
| R-6 | FAIL | FAIL | `test_rebuild.lua::R-6 hand-made > hand-made recycling untouched after source change` |
| R-7 | FAIL | FAIL | `test_rebuild.lua::R-7 game-built test > game name with foreign icon counts as hand-made` |
| R-8 | FAIL | FAIL | `test_rebuild.lua::R-8 rejected source > auto_recycle false keeps current recycling` |
| R-9 | FAIL | FAIL | `test_rebuild.lua::R-9 unlocks > *` (2) |
| R-10 | NOT-TESTED | NOT-TESTED | headless vanilla run, zero changes |
| S-1 | FAIL | FAIL | `test_settings.lua::S-1 excluded > *` (3) |
| S-2 | FAIL | FAIL | `test_settings.lua::S-2 self-recycling switch > *` (3) |
| S-3 | NOT-TESTED | NOT-TESTED | `locale/en/locale.cfg` (L002) |
| L-1 | FAIL | FAIL | `test_rebuild.lua::L-1 report > log has prefix, counts and per-recipe line` |
| P-1 | NOT-TESTED | NOT-TESTED | `make zip` listing (L004) |
| P-2 | NOT-TESTED | NOT-TESTED | `thumbnail.png` 144x144 (L004) |
| P-3 | NOT-TESTED | NOT-TESTED | `changelog.txt` (L004) |
| P-4 | PASS | n/a | `make full-check` 2026-10-09: added 2, fixed 5, self 1, `full-check-2.0-ok` (pre-module code) |

Headless planted suite `tests/game/run.sh` 2026-10-09: 2.0 PASS without-fix, PASS with-fix; 2.1 PASS without-fix, with-fix load error (R-1).
