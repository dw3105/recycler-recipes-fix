# Recycler Recipes Fix

A Factorio data-stage mod that rebuilds missing and stale recycling recipes after mods have loaded, using the game's own recipe builder.

## Build and checks

Run `make help` to list repository targets. Build both distributable archives with `make zip`; build one with `tools/make_zip.sh 2.0` or `tools/make_zip.sh 2.1`. Archives are written to `build/`.

Offline checks are available through `make test-offline`. The full game check requires local Factorio data and is run by the integrator before release.

## Release

Push a `v*` tag from the release operator's laptop. GitHub Actions builds the Factorio 2.0 and 2.1 zips, creates `SHA256SUMS.txt`, and publishes those files with the newest changelog block as the GitHub release notes. Uploading the matching zip to the Factorio mod portal is a manual operator step.
