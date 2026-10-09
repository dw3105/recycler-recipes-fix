local version = mods["recycler"] and "2.1" or "2.0"
local recycling
if version == "2.1" then
  recycling = require("__recycler__.recycling")
else
  recycling = require("__quality__.prototypes.recycling")
end

local excluded = {}
for name in string.gmatch(settings.startup["rrf-excluded-items"].value, "[^,]+") do
  name = string.gsub(name, "^%s*(.-)%s*$", "%1")
  if name ~= "" then excluded[name] = true end
end

require("scripts.rebuild").run{
  recycling = recycling,
  version = version,
  excluded = excluded,
  self_recycling = settings.startup["rrf-add-self-recycling"].value,
}
