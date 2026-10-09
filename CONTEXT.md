# Recycler Recipes Fix

Rebuilds recycler recipes after every mod has loaded, so recipes added or changed late recycle correctly.

## Language

**Recycling recipe**:
The recipe a recycler runs on one item; named `<item>-recycling`.
_Avoid_: reverse recipe, scrap recipe

**Source recipe**:
A normal recipe whose single item result is the item a recycling recipe takes.

**Game rules**:
How the Factorio version in use builds recycling recipes from source recipes (2.0: `quality` mod; 2.1: `recycler` mod), applied unchanged.
_Avoid_: vanilla rules, quality rules

**Missing**:
An item has a source recipe the game rules accept, but no recycling recipe.

**Stale**:
A recycling recipe built by the game rules from an older version of its source recipe, so its results no longer match.

**Self-recycling**:
A recycling recipe that returns the item itself with 25% chance; the game's fallback for items with no usable source recipe.

**Game-built**:
A recycling recipe whose name is the game's recycling name and whose first icon is the game's recycling icon, whoever called the builder. Only game-built and self-recycling recipes may be rebuilt.

**Hand-made**:
Any recycling recipe that is not game-built or self-recycling; never touched.

**Excluded item**:
An item the player lists so this mod never touches its recycling recipe.
