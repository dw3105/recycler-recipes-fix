local function item(n) local i = table.deepcopy(data.raw.item["iron-gear-wheel"]); i.name = n; return i end
-- 1 new item+recipe after quality ran -> expect added
data:extend{item("rrf-widget"), {type="recipe", name="rrf-widget", ingredients={{type="item",name="iron-gear-wheel",amount=8},{type="item",name="copper-plate",amount=4}}, results={{type="item",name="rrf-widget",amount=1}}}}
-- 2 changed vanilla recipe -> expect iron-chest-recycling fixed
data.raw.recipe["iron-chest"].ingredients = {{type="item",name="copper-plate",amount=8}}
-- 3 hand-made recycling + changed recipe -> must stay untouched
data.raw.recipe["steel-chest-recycling"].localised_name = "custom"
data.raw.recipe["steel-chest-recycling"].results = {{type="item",name="stone",amount=3}}
data.raw.recipe["steel-chest"].ingredients = {{type="item",name="copper-plate",amount=8}}
-- 4 item without recipe -> expect self-recycling added
data:extend{item("rrf-orphan")}
