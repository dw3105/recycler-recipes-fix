---
name: recycler-recipes-fix-code
description: "Working rule for recycler-recipes-fix, Factorio 2.0 + 2.1 data-stage mod that rebuilds recycling recipes with the game's own builder: requirements contract, frozen owner contract tests, lanes run single offline lua5.2 tests only, headless Factorio only at integrator merge and release, both versions, no push from VM. Read before editing scripts/, tests/, data-final-fixes.lua, settings.lua, info.json, or claiming anything about this repo."
---

## What this enforces, and what it does not

| State | Rules |
|---|---|
| Machine check | RF-02 partial: `tests/game/run.sh` and `tests/game/full_check.sh` exit 2 when `LANE_RUN_ID` set |
| Human checklist | RF-01, RF-03 .. RF-09 |

**v0.1 - 9 Oct 2026.** File caveman full. Change log in `references/ledger.md`; incident per rule in `references/incidents.md`. Rules ported from sushi-packer (`skills/sushi-packer-code`) and shared `codex-tasks`. Canonical copy `skills/recycler-recipes-fix-code/` in this repo; live copy installed by `make skill-install` from clean `main` only. `docs/REQUIREMENTS.md` outranks this skill.

Lane calling Factorio binary direct meets no stop, only task ban and reviewer read of lane log. Integrator greps lane log for `factorio`, `make test ` and `tests/game` before merge. Green lint prove copy match only, never rule read or obeyed.

## Code and tests

- **RF-01** **Owner contract tests frozen.** `tests/offline/run.lua`, `env.lua`, `test_rebuild.lua`, `test_settings.lua`. Lane never edits or weakens them; change = integrator decision in `docs/adr/`.
- **RF-02** **Lanes run single offline tests only.** `make test-one FV=<2.0|2.1> T='tests/offline/<file>.lua::<describe> > <it>'`, plus lane's own new offline file whole. Never Factorio, never `tests/game/*`, never `make test`.
- **RF-03** **Call game builder, never copy it.** 2.0 `__quality__.prototypes.recycling`, 2.1 `__recycler__.recycling` Offline tests load same file from `~/factorio-<FV>/factorio/data`, so test checks real game rules, never lane's copy of them. Copied builder drifts on next Factorio release and fixes recipes game would build differently.
- **RF-04** **Both versions.** Offline and headless result counts only when run on `FV=2.0` and `FV=2.1`. 2.1 traps: `categories` list not `category`; self-recycling `independent_probability` not `probability`; builder appends unlock to `technology.recycling.effects` every call, so discarded candidate leaves stray unlock unless removed.
- **RF-05** **Red first.** Every new test seen failing before code (`proving`). Owner contract tests were red at base 2026-10-09: 17 of 17 failed per version, `module 'scripts.rebuild' not found`. Green without seen red is not evidence.

## Evidence, shipping

- **RF-06** **Requirement IDs are progress.** Each ID PASS / FAIL / NOT-TESTED per version in `docs/REQ-STATUS.md` with test name or command. Never "works" without run.
- **RF-07** **No push from VM.** Push URL `DISABLED`; operator pushes, tags `v*` and uploads zips to mod portal from laptop. VM holds no GitHub login; commit in worktree, merge into `~/recycler-recipes-fix-mod` main.
- **RF-08** **Full mod-set check before release.** `make full-check` loads 51 mods of author's 2026-10-08 log plus this mod; result line in REQ-STATUS with date and counts. Planted suite proves mechanism only; real mod set proves no load error and shows which recipes change.
- **RF-09** **Never ship file copied from base game.** Release zip holds only whitelist files in requirements Release section. Thumbnail is own art drawn by script; headless install has no graphics to copy anyway.

## skill check

`skill check` → this line, nothing else:

```
recycler-recipes-fix-code v0.1: owner contract tests frozen | lanes single offline lua5.2 tests only, headless integrator only | call game builder never copy | both versions, 2.1 categories, independent_probability, unlock effects | red first | requirement IDs are progress | no push from VM | full mod-set check before release | no base-game file shipped
```
