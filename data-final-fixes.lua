-- Rebuild recycling recipes after every mod has run.
-- quality builds them once in its data-updates.lua; recipes added or changed later
-- end up self-recycling or stale. Hand-made recycling recipes are left alone.
local util = require("util")
local recycling = require("__quality__.prototypes.recycling")
local recipes = data.raw.recipe

local function single_item_product(recipe)
  if not recipe.results then return end
  local found
  for _, p in pairs(util.normalize_recipe_products(recipe)) do
    if p.type == "item" then
      if found then return end
      if p.amount_min ~= p.amount_max then return end
      found = p.name
    end
  end
  return found
end

local function is_self(r, item)
  local res = r.results
  return res and #res == 1 and res[1].name == item and res[1].probability == 0.25
end

local function is_auto(r)
  local ln = r.localised_name
  local icon = r.icons and r.icons[1] and r.icons[1].icon
  return type(ln) == "table" and ln[1] == "recipe-name.recycling"
    and icon == "__quality__/graphics/icons/recycling.png"
end

local function same_results(a, b)
  local ra, rb = a.results or {}, b.results or {}
  if #ra ~= #rb then return false end
  for i = 1, #ra do
    local x, y = ra[i], rb[i]
    if x.name ~= y.name or x.amount ~= y.amount
      or (x.extra_count_fraction or 0) ~= (y.extra_count_fraction or 0)
      or (x.probability or 1) ~= (y.probability or 1) then
      return false
    end
  end
  return true
end

-- Generate a fresh candidate per producing recipe without keeping it yet.
local candidates = {} -- target name -> list of {recipe = name, proto = table}
local names = {}
for name in pairs(recipes) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do
  local recipe = recipes[name]
  local item = recipe and recipe.category ~= "recycling" and single_item_product(recipe)
  if item then
    local target = item .. "-recycling"
    local old = recipes[target]
    recycling.generate_recycling_recipe(recipe)
    local new = recipes[target]
    recipes[target] = old
    if new and new ~= old then
      candidates[target] = candidates[target] or {}
      table.insert(candidates[target], {recipe = name, item = item, proto = new})
    end
  end
end

local added, fixed = {}, {}
local targets = {}
for t in pairs(candidates) do targets[#targets + 1] = t end
table.sort(targets)
for _, target in ipairs(targets) do
  local list = candidates[target]
  local old = recipes[target]
  if not old then
    recipes[target] = list[1].proto
    added[#added + 1] = target .. " <- " .. list[1].recipe
  elseif is_self(old, list[1].item) or is_auto(old) then
    local still_valid = false
    for _, c in ipairs(list) do
      if same_results(old, c.proto) then still_valid = true break end
    end
    if not still_valid then
      recipes[target] = list[1].proto
      fixed[#fixed + 1] = target .. " <- " .. list[1].recipe
    end
  end
end

-- Items still without any recycling recipe get the vanilla self-recycling one.
local self_added = {}
for type_name in pairs(defines.prototypes.item) do
  for name, item in pairs(data.raw[type_name] or {}) do
    if item.auto_recycle ~= false and not item.parameter
      and not recipes[name .. "-recycling"] and not string.find(name, "-barrel") then
      recycling.generate_self_recycling_recipe(item)
      self_added[#self_added + 1] = name .. "-recycling"
    end
  end
end
table.sort(self_added)

local function report(label, list)
  log(string.format("[recycler-recipes-fix] %s: %d", label, #list))
  for _, line in ipairs(list) do log("[recycler-recipes-fix]   " .. line) end
end
report("added", added)
report("fixed", fixed)
report("self-recycling added", self_added)
