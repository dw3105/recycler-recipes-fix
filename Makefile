# recycler-recipes-fix - build and gate. `make help` lists targets.
SHELL := /bin/bash
.DEFAULT_GOAL := help
FV ?= 2.0
WORK ?= build/game
GATE := $(if $(shell command -v gateslot),gateslot --label recycler-recipes-fix-mod/heavy --,)
SKILL := recycler-recipes-fix-code

.PHONY: help test-one test-offline test full-check ci-collect skill-lint skill-check skill-install zip verify

help: ## List targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "%-14s %s\n", $$1, $$2}'

test-one: ## One offline test: make test-one FV=2.1 T='tests/offline/test_rebuild.lua::R-2 missing > late recipe gets game-built recycling'. Lanes use only this
	@test -n "$(T)" || { echo "usage: make test-one FV=<2.0|2.1> T='<file>::<describe> > <it>'" >&2; exit 2; }
	FV=$(FV) lua5.2 tests/offline/run.lua "$$(echo '$(T)' | sed 's/::.*//')" "$$(echo '$(T)' | sed 's/^[^:]*:://')"

test-offline: ## Every offline test file, both versions (lua5.2, ms)
	@set -eo pipefail; for fv in 2.0 2.1; do for f in tests/offline/test_*.lua; do FV=$$fv lua5.2 tests/offline/run.lua $$f | tail -1; done; done

test: ## FULL suite on FV: offline + headless planted-mod run (gateslot heavy). Integrator only
	@set -eo pipefail; for f in tests/offline/test_*.lua; do FV=$(FV) lua5.2 tests/offline/run.lua $$f | tail -1; done
	$(GATE) tests/game/run.sh $(FV) $(WORK)

full-check: ## P-4: 51-mod set of the 2026-10-08 log, newest 2.0 releases, plus this mod. Integrator only, before release
	python3 -I tools/fetch_mods.py ~/share/recycler-recipes-fix/factorio-current.log 2.0
	$(GATE) tests/game/full_check.sh 2.0 $(WORK)

ci-collect: ## List offline test names, runs nothing
	@for f in tests/offline/test_*.lua; do grep -oE '(describe|it)\("[^"]+"' $$f | sed "s|^|$$f: |"; done

skill-lint: ## Estate skill lint on skills/
	/usr/local/bin/lint_skill.py --all skills --budget 10000 --register --citations --token-gate=measure

skill-check: ## Fail if live ~/.claude/skills/$(SKILL) drifted from repo copy
	python3 ~/skills/tools/skill_install.py --src skills/$(SKILL) --live ~/.claude/skills/$(SKILL) --check --allow-missing-live

skill-install: ## Copy repo skill live; refuses unless on main with clean skills/
	@test "$$(git rev-parse --abbrev-ref HEAD)" = main || { echo "skill-install: refuse, branch not main"; exit 1; }
	@test -z "$$(git status --porcelain -- skills/$(SKILL))" || { echo "skill-install: refuse, uncommitted skill changes"; exit 1; }
	python3 ~/skills/tools/skill_install.py --src skills/$(SKILL) --live ~/.claude/skills/$(SKILL) --force
	$(MAKE) skill-check

zip: ## Both release zips into build/ (tools/make_zip.sh, lane L004)
	tools/make_zip.sh 2.0 && tools/make_zip.sh 2.1

verify: ## skill-lint, offline both versions, full suite 2.0 and 2.1, skill-check
	$(MAKE) skill-lint && $(MAKE) test-offline && $(MAKE) test FV=2.0 && $(MAKE) test FV=2.1 && $(MAKE) skill-check
