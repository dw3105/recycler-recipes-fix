# 001 — rebuild module both versions

Repo `/home/dev_zaigraev_gmail_com/recycler-recipes-fix-mod`.

## What is true

**PRESERVE:** owner contract tests `tests/offline/run.lua`, `tests/offline/env.lua`, `tests/offline/test_rebuild.lua`, `tests/offline/test_settings.lua` stay byte-identical. Contract `docs/REQUIREMENTS.md` stays byte-identical. Mod stays data stage only: no `control.lua`.

- `data-final-fixes.lua:5` requires `__quality__.prototypes.recycling`; that path exists only on Factorio 2.0. On 2.1 the builder is `__recycler__.recycling` (`/home/dev_zaigraev_gmail_com/factorio-2.1/factorio/data/recycler/recycling.lua:262-263` exports `generate_recycling_recipe`, `generate_self_recycling_recipe`). 2.0 builder: `/home/dev_zaigraev_gmail_com/factorio-2.0/factorio/data/quality/prototypes/recycling.lua:247-248`.
- `data-final-fixes.lua:8-109` holds working 2.0 logic: candidate per source recipe built by calling the game builder then restoring the old table (`:52-66`), keep-if-any-candidate-matches (`:72-88`), self-recycling pass (`:91-100`), log report (`:102-109`). Move this logic into the module; do not rewrite rules.
- Game builder writes straight into `data.raw.recipe` (2.0 `recycling.lua:217`, 2.1 `recycling.lua:231`); target name is `<item>-recycling` (2.0 `:149`, 2.1 `:152`).
- 2.1 trap A: builder appends `{type = "unlock-recipe", recipe = <name>, hidden = true}` to `data.raw.technology.recycling.effects` on every call (2.1 `recycling.lua:191-196`, called from `:230` and from self-recycling). A candidate this module discards must leave no entry; a recipe this module adds or replaces ends with exactly one entry (R-9). 2.0 builder touches no technology.
- 2.1 trap B: recycling recipes carry `categories = {"recycling"}` (2.1 `:221`, `:247`), not `category = "recycling"` (2.0 `:209`, `:233`). Source-recipe scan must skip recycling recipes under both shapes.
- 2.1 trap C: self-recycling result uses `independent_probability = 0.25` (2.1 `:252`); 2.0 uses `probability = 0.25` (2.0 `:238`). Self-recycling detection reads the version's key.
- Game-built test (R-7): `localised_name[1] == "recipe-name.recycling"` and `icons[1].icon` equals `__quality__/graphics/icons/recycling.png` (2.0) or `__recycler__/graphics/icons/recycling.png` (2.1).
- Seam the owner tests call, `tests/offline/env.lua:68-77`: `require("scripts.rebuild").run(opts)`; `opts.recycling` = game builder lib, `opts.version` = `"2.0"` or `"2.1"`, `opts.excluded` = set `{[item_name] = true}`, `opts.self_recycling` = bool. Returns report table with lists `added`, `fixed`, `self_added`, `excluded` of strings `"<recycling> <- <source>"` (added, fixed) or `"<recycling>"` (self_added, excluded). Module reads globals `data`, `defines`, `log` inside `run`, never at file load.
- `settings.lua:1-17` defines startup settings `rrf-excluded-items` (string, comma-separated) and `rrf-add-self-recycling` (bool, default true).
- Owner tests: 11 in `test_rebuild.lua`, 6 in `test_settings.lua`, all red at base per version with `module 'scripts.rebuild' not found`.

## What to build

1. `scripts/rebuild.lua`: module returning `{run = function(opts) ... end}` meeting R-2..R-9, S-1, S-2, L-1 for both versions, using only `opts.recycling` for building.
2. `data-final-fixes.lua`: thin wiring only. Version = `"2.1"` when global `mods["recycler"]` is set, else `"2.0"`. Lib = `require("__recycler__.recycling")` on 2.1, `require("__quality__.prototypes.recycling")` on 2.0. Excluded set parsed from `settings.startup["rrf-excluded-items"].value` (split on `,`, trim spaces, skip empty). `self_recycling = settings.startup["rrf-add-self-recycling"].value`. Call `require("scripts.rebuild").run{...}`.
3. Lane forbidden: editing any PRESERVE file, editing this task file, weakening or deleting any test, running Factorio, running anything under `tests/game/`, running `make test`.

## What done mean

```checks
{"name": "lane001-scope", "command": "git diff --name-only $(git merge-base main HEAD) HEAD | grep -Ev '^(scripts/rebuild\\.lua|data-final-fixes\\.lua)$' | ( ! grep . ) && echo lane001-scope-ok", "expect_exit": 0, "expect_regex": "lane001-scope-ok", "timeout_s": 60, "red_at_base": false}
{"name": "lane001-rebuild-2.0", "command": "out=$(FV=2.0 lua5.2 tests/offline/run.lua tests/offline/test_rebuild.lua) && printf '%s\\n' \"$out\" | grep -q '^tests/offline/test_rebuild.lua: 11 run, 0 failed (FV=2.0)$' && echo lane001-rebuild-2.0-ok", "expect_exit": 0, "expect_regex": "lane001-rebuild-2.0-ok", "timeout_s": 120}
{"name": "lane001-rebuild-2.1", "command": "out=$(FV=2.1 lua5.2 tests/offline/run.lua tests/offline/test_rebuild.lua) && printf '%s\\n' \"$out\" | grep -q '^tests/offline/test_rebuild.lua: 11 run, 0 failed (FV=2.1)$' && echo lane001-rebuild-2.1-ok", "expect_exit": 0, "expect_regex": "lane001-rebuild-2.1-ok", "timeout_s": 120}
{"name": "lane001-settings-both", "command": "for fv in 2.0 2.1; do out=$(FV=$fv lua5.2 tests/offline/run.lua tests/offline/test_settings.lua) || exit 1; printf '%s\\n' \"$out\" | grep -q \"^tests/offline/test_settings.lua: 6 run, 0 failed (FV=$fv)$\" || exit 1; done && echo lane001-settings-ok", "expect_exit": 0, "expect_regex": "lane001-settings-ok", "timeout_s": 120}
{"name": "lane001-frozen", "command": "git diff --quiet $(git merge-base main HEAD) HEAD -- tests/offline docs/REQUIREMENTS.md settings.lua && test ! -e control.lua && echo lane001-frozen-ok", "expect_exit": 0, "expect_regex": "lane001-frozen-ok", "timeout_s": 60, "red_at_base": false}
```

Green at base, by design: lane001-scope (no diff yet), lane001-frozen (no diff yet). Owner base colours (`main` 51be383, scratch `HOME`, 2026-10-09): lane001-scope GREEN, lane001-rebuild-2.0 RED (11 failed), lane001-rebuild-2.1 RED (11 failed), lane001-settings-both RED (6 failed), lane001-frozen GREEN.

## Files this lane owns

- `scripts/rebuild.lua` (new)
- `data-final-fixes.lua`

Re-cut because: none

# bound: 1800s

Reviewer ask: does `scripts/rebuild.lua` call only `opts.recycling` to build recipes (no copied builder logic), leave hand-made recycling recipes untouched, and leave exactly one 2.1 unlock entry per added or replaced recipe?
