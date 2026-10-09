-- Fresh data-stage globals per test, with the REAL game recycling builder of FV.
-- Frozen seam: lanes never edit this file.
local env = {}
env.fv = os.getenv("FV") or "2.0"
local game = os.getenv("HOME") .. "/factorio-" .. env.fv .. "/factorio/data"
local root = debug.getinfo(1, "S").source:sub(2):gsub("tests/offline/env%.lua$", "")
package.path = root .. "?.lua;" .. game .. "/core/lualib/?.lua;" .. package.path
env.icon = env.fv == "2.0" and "__quality__/graphics/icons/recycling.png" or "__recycler__/graphics/icons/recycling.png"
env.prob_key = env.fv == "2.0" and "probability" or "independent_probability"

function env.fresh()
  data = {raw = {recipe = {}, item = {}, ammo = {}, fluid = {}, technology = {recycling = {effects = {}}}}}
  function data:extend(list)
    for _, p in ipairs(list) do
      self.raw[p.type] = self.raw[p.type] or {}
      self.raw[p.type][p.name] = p
    end
  end
  defines = setmetatable({prototypes = {item = {item = 0, ammo = 0}}, default_icon_size = 64,
    constant = {default_icon_size = 64}},
    {__index = function(t, k) local v = setmetatable({}, {__index = function() return 0 end}); rawset(t, k, v); return v end})
  mods = env.fv == "2.0" and {base = "2.0.77", quality = "2.0.77"} or {base = "2.1.20", recycler = "2.1.20"}
  env.logs = {}
  log = function(s) env.logs[#env.logs + 1] = s end
  package.loaded.util = nil
  local path = env.fv == "2.0" and game .. "/quality/prototypes/recycling.lua" or game .. "/recycler/recycling.lua"
  env.lib = dofile(path)
  return env
end

function env.item(name, extra)
  local i = {type = "item", name = name, icon = "__test__/" .. name .. ".png", icon_size = 64, stack_size = 50}
  for k, v in pairs(extra or {}) do i[k] = v end
  data.raw[i.type] = data.raw[i.type] or {}
  data.raw[i.type][name] = i
  return i
end

function env.recipe(name, ingredients, result, extra)
  local r = {type = "recipe", name = name, ingredients = {}, results = {{type = "item", name = result or name, amount = 1}}}
  for n, a in pairs(ingredients) do r.ingredients[#r.ingredients + 1] = {type = "item", name = n, amount = a} end
  table.sort(r.ingredients, function(a, b) return a.name < b.name end)
  for k, v in pairs(extra or {}) do r[k] = v end
  data.raw.recipe[name] = r
  return r
end

-- results of a recipe as "name=amount" joined, sorted
function env.results(name)
  local r = data.raw.recipe[name]
  if not r then return "NONE" end
  local out = {}
  for _, e in ipairs(r.results or {}) do out[#out + 1] = e.name .. "=" .. tostring(e.amount) end
  table.sort(out)
  return table.concat(out, ",")
end

function env.unlocks(name)
  local n = 0
  for _, e in ipairs(data.raw.technology.recycling.effects) do
    if e.type == "unlock-recipe" and e.recipe == name then n = n + 1 end
  end
  return n
end

-- The seam under test: scripts/rebuild.lua returns {run = function(opts) -> report}.
function env.run(opts)
  package.loaded["scripts.rebuild"] = nil
  local rebuild = require("scripts.rebuild")
  opts = opts or {}
  if opts.recycling == nil then opts.recycling = env.lib end
  if opts.version == nil then opts.version = env.fv end
  if opts.excluded == nil then opts.excluded = {} end
  if opts.self_recycling == nil then opts.self_recycling = true end
  return rebuild.run(opts)
end

function env.has(list, s)
  for _, v in ipairs(list or {}) do if v == s then return true end end
  return false
end

return env
