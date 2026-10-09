# Recycler Recipes Fix

Some mods add or change crafting recipes late in Factorio's load order. The game's recycling recipes are built before those late changes are available, so an item can be left without a recycling recipe, keep an outdated result, or receive an incorrect self-recycling recipe.

Recycler Recipes Fix runs in the data final fixes stage and uses the game's own recycling recipe builder after the full mod set has loaded. It adds missing recipes, updates stale game-built recipes, and handles self-recycling recipes while leaving hand-made recycling recipes alone. It also reports what it changed in the Factorio log.

Two builds are provided from the same source: the Factorio 2.0 build depends on `quality`, and the Factorio 2.1 build depends on `recycler`. Install the build matching your Factorio version.

The startup setting `rrf-excluded-items` accepts a comma-separated list of item names that the rebuild should leave alone. The `rrf-add-self-recycling` setting controls whether eligible items without a recycling recipe receive a self-recycling recipe.

To read the report, search the log for `[recycler-recipes-fix]`. Count lines summarize added, fixed, self-recycling, and excluded recipes; individual lines show the recycling recipe and its source recipe where applicable. A mod missed by the curated load-order list may still load too late for this rebuild. If you find one, please report the mod and a reproducible example so the dependency list can be updated.
