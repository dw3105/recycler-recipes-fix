# recycler-recipes-fix — requirements

Status: v1, 2026-10-09. Contract. Outranks every other doc. Only author (dw3105) amends it. Terms as in `CONTEXT.md`. Proof per clause in `docs/REQ-STATUS.md`.

## 1. Target

| ID | Requirement |
|---|---|
| T-1 | Two builds from one source: Factorio 2.0 as `0.1.x`, Factorio 2.1 as `0.2.x`; same `x` for same release. |
| T-2 | Data stage only. No `control.lua`, no runtime script. |
| T-3 | Hard dependency: `quality` on 2.0, `recycler` on 2.1. |
| T-4 | Load order: hidden optional dependencies `(?) <mod>` on a curated list of recipe-changing mods in `info.json`; name stays `recycler-recipes-fix`. |

## 2. Rebuild

| ID | Requirement |
|---|---|
| R-1 | Game rules are the version's own builder, called, never copied: 2.0 `__quality__.prototypes.recycling`, 2.1 `__recycler__.recycling`. |
| R-2 | Missing: item whose source recipe the game rules accept, with no recycling recipe, gets the game-built recycling recipe. |
| R-3 | Stale: game-built recycling recipe whose results equal the game-rules output of no current source recipe is replaced by game-rules output of first source recipe in name order. |
| R-4 | Still valid: game-built recycling recipe whose results equal game-rules output of any current source recipe stays unchanged (same table). |
| R-5 | Self-recycling recipe is replaced when a source recipe the game rules accept exists. |
| R-6 | Hand-made recycling recipe is never changed, removed or replaced. |
| R-7 | Game-built test: `localised_name[1] == "recipe-name.recycling"` and first icon is the version's `recycling.png` (`__quality__/graphics/icons/recycling.png` on 2.0, `__recycler__/graphics/icons/recycling.png` on 2.1). |
| R-8 | Source recipes the game rules reject (category, `auto_recycle = false`, multi-result) yield nothing; their item keeps its current recycling recipe. |
| R-9 | 2.1: technology `recycling` effects hold exactly one `unlock-recipe` entry per recycling recipe this mod adds or replaces; candidates discarded leave no entry. |
| R-10 | With only built-in mods (`base`, `quality`, `space-age`, `elevated-rails`, and `recycler` on 2.1) this mod changes zero recipes. |

## 3. Settings

| ID | Requirement |
|---|---|
| S-1 | Startup string setting `rrf-excluded-items`: comma-separated item names, spaces ignored, default empty. No recycling recipe of a listed item is added, replaced or removed. |
| S-2 | Startup bool setting `rrf-add-self-recycling`, default `true`. When true, every item with no recycling recipe after rebuild, `auto_recycle ~= false`, not `parameter`, name without `-barrel`, gets the version's self-recycling recipe. When false, none added. |
| S-3 | Setting names and descriptions in `locale/en/locale.cfg` only. |

## 4. Report

| ID | Requirement |
|---|---|
| L-1 | Log only (`log()`), prefix `[recycler-recipes-fix]`. One count line each for added, fixed, self-recycling added, excluded; one line per recipe: `<recycling recipe> <- <source recipe>` (added, fixed) or `<recycling recipe>` (self, excluded). |

## 5. Release

| ID | Requirement |
|---|---|
| P-1 | Release zip holds only `info.json`, `settings.lua`, `data-final-fixes.lua`, `scripts/`, `locale/`, `changelog.txt`, `thumbnail.png`, `LICENSE`. |
| P-2 | `thumbnail.png` 144x144, original art, no file copied from the base game. |
| P-3 | `changelog.txt` in Factorio changelog format, one entry per build. |
| P-4 | Before release: full mod-set check on 2.0 (51 mods of the 2026-10-08 log) loads with zero errors. |
