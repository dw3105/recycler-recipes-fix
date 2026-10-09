local M = {}

function M.run(opts)
  local util = require("util")
  local recipes = data.raw.recipe
  local excluded = opts.excluded or {}
  local version = opts.version
  local recycling = opts.recycling
  local report = {added = {}, fixed = {}, self_added = {}, excluded = {}}

  local function single_item_product(recipe)
    if not recipe.results then return end
    local found
    for _, p in pairs(util.normalize_recipe_products(recipe)) do
      if p.type == "item" then
        if found or p.amount_min ~= p.amount_max then return end
        found = p.name
      end
    end
    return found
  end

  local function is_self(recipe, item)
    local result = recipe.results
    local key = version == "2.1" and "independent_probability" or "probability"
    return result and #result == 1 and result[1].name == item and result[1][key] == 0.25
  end

  local function is_auto(recipe)
    local name = recipe.localised_name
    local icon = recipe.icons and recipe.icons[1] and recipe.icons[1].icon
    local prefix = version == "2.1" and "__recycler__" or "__quality__"
    return type(name) == "table" and name[1] == "recipe-name.recycling"
      and icon == prefix .. "/graphics/icons/recycling.png"
  end

  local function same_results(a, b)
    local ra, rb = a.results or {}, b.results or {}
    if #ra ~= #rb then return false end
    for i = 1, #ra do
      local x, y = ra[i], rb[i]
      if x.name ~= y.name or x.amount ~= y.amount
        or (x.extra_count_fraction or 0) ~= (y.extra_count_fraction or 0)
        or (x.probability or x.independent_probability or 1) ~= (y.probability or y.independent_probability or 1) then
        return false
      end
    end
    return true
  end

  local function technology_effects()
    local tech = data.raw.technology and data.raw.technology.recycling
    return tech and tech.effects
  end

  -- Candidate generation is isolated from both recipe storage and 2.1's unlock side effect.
  local candidates, names = {}, {}
  for name in pairs(recipes) do names[#names + 1] = name end
  table.sort(names)
  for _, name in ipairs(names) do
    local recipe = recipes[name]
    local item = recipe and recipe.category ~= "recycling"
      and not (recipe.categories and (function()
        for _, category in pairs(recipe.categories) do if category == "recycling" then return true end end
      end)()) and single_item_product(recipe)
    if item then
      local target = item .. "-recycling"
      local old = recipes[target]
      local effects = technology_effects()
      local effect_snapshot
      if effects then
        effect_snapshot = {}
        for i, effect in ipairs(effects) do effect_snapshot[i] = effect end
      end
      recycling.generate_recycling_recipe(recipe)
      local generated = recipes[target]
      recipes[target] = old
      if effects then
        for i = #effects, 1, -1 do effects[i] = nil end
        for i, effect in ipairs(effect_snapshot) do effects[i] = effect end
      end
      if generated and generated ~= old then
        candidates[target] = candidates[target] or {}
        table.insert(candidates[target], {recipe = name, item = item, proto = generated})
      end
    end
  end

  local function ensure_unlock(target)
    if version ~= "2.1" then return end
    local effects = technology_effects()
    if not effects then return end
    for i = #effects, 1, -1 do
      local effect = effects[i]
      if effect.type == "unlock-recipe" and effect.recipe == target then table.remove(effects, i) end
    end
    effects[#effects + 1] = {type = "unlock-recipe", recipe = target, hidden = true}
  end

  local targets = {}
  for target in pairs(candidates) do targets[#targets + 1] = target end
  table.sort(targets)
  for _, target in ipairs(targets) do
    local list, old = candidates[target], recipes[target]
    if excluded[list[1].item] then
      report.excluded[#report.excluded + 1] = target
    elseif not old then
      recipes[target] = list[1].proto
      report.added[#report.added + 1] = target .. " <- " .. list[1].recipe
      ensure_unlock(target)
    elseif is_self(old, list[1].item) or is_auto(old) then
      local valid = false
      for _, candidate in ipairs(list) do
        if same_results(old, candidate.proto) then valid = true; break end
      end
      if not valid then
        recipes[target] = list[1].proto
        report.fixed[#report.fixed + 1] = target .. " <- " .. list[1].recipe
        ensure_unlock(target)
      end
    end
  end

  if opts.self_recycling then
    for type_name in pairs(defines.prototypes.item) do
      for name, item in pairs(data.raw[type_name] or {}) do
        if item.auto_recycle ~= false and not item.parameter and not excluded[name]
          and not recipes[name .. "-recycling"] and not string.find(name, "-barrel") then
          recycling.generate_self_recycling_recipe(item)
          report.self_added[#report.self_added + 1] = name .. "-recycling"
          ensure_unlock(name .. "-recycling")
        end
      end
    end
  end

  table.sort(report.added); table.sort(report.fixed); table.sort(report.self_added); table.sort(report.excluded)
  local function log_report(label, list)
    log(string.format("[recycler-recipes-fix] %s: %d", label, #list))
    for _, line in ipairs(list) do log("[recycler-recipes-fix]   " .. line) end
  end
  log_report("added", report.added)
  log_report("fixed", report.fixed)
  log_report("self-recycling added", report.self_added)
  log_report("excluded", report.excluded)
  return report
end

return M
