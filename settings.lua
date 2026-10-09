data:extend({
  {
    type = "string-setting",
    name = "rrf-excluded-items",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    order = "a",
  },
  {
    type = "bool-setting",
    name = "rrf-add-self-recycling",
    setting_type = "startup",
    default_value = true,
    order = "b",
  },
})
