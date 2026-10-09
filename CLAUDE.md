# recycler-recipes-fix — repository facts

Factorio mod, two builds from one source: 2.0 (`0.1.x`, needs `quality`) and 2.1 (`0.2.x`, needs `recycler`). Data stage only: rebuilds recycling recipes after every mod loaded, with the game's own builder. Register: **caveman full**.

## Read first, every session

1. `docs/REQUIREMENTS.md` — contract. Outranks every other doc. Only author amends it.
2. Repo skill `recycler-recipes-fix-code` (`skills/recycler-recipes-fix-code/SKILL.md`).
3. `CONTEXT.md` (terms), `docs/REQ-STATUS.md`, `docs/adr/`, `docs/FINDINGS.md`.
4. Shared skills leaned on: `codex-tasks`, `proving`, `evidence-and-claims`, `shared-host`, `session-lifecycle`, `operator-blocks`, `shipping-and-integration`, `talking-to-operator`.

## Machine map

| Machine | Who | May |
|---|---|---|
| `dev-vm` (this VM, shared) | agents, codex lanes | edit, single offline tests, commit in worktree. Never `git push` |
| operator laptop | operator | `gh repo create`, `git push`, tag release, portal upload, play-test |

Headless Factorio: `~/factorio-2.0/factorio` (2.0.77), `~/factorio-2.1/factorio` (2.1.20). Game builder: 2.0 `data/quality/prototypes/recycling.lua`, 2.1 `data/recycler/recycling.lua`. Mod portal creds `~/.factorio-portal` (read by `tools/fetch_mods.py` only).

## Build

- `make test-one FV=<2.0|2.1> T='tests/offline/<file>.lua::<describe> > <it>'` — one offline test, real game builder, fake data. Lanes use only this.
- `make test-offline` — all offline files, both versions.
- `make test FV=<2.0|2.1>` — offline + headless planted-mod suite, gateslot `recycler-recipes-fix-mod/heavy`. Integrator only (refused under `LANE_RUN_ID`).
- `make full-check` — P-4, 51-mod set on 2.0. Integrator only, before release.
- `make zip` — two zips in `build/`.

## Hard rules

- Only gateslot labels `recycler-recipes-fix-mod/heavy` and `recycler-recipes-fix-mod/agent`.
- Owner contract tests `tests/offline/test_rebuild.lua`, `test_settings.lua`, `env.lua`, `run.lua` frozen: lanes never edit or weaken.
- Seam: `scripts/rebuild.lua` returns `{run = function(opts) -> report}`; opts `recycling, version, excluded, self_recycling`; report lists `added, fixed, self_added, excluded`.
- Call the game builder, never copy it (R-1). Never ship a file copied from the base game.
- Never commit `build/`, `*.zip`, `.env`.
