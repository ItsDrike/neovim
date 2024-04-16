-- Define highlightings using TreeSitter groups
-- (the onedarker colorscheme doesn't seem to have native support for this)

local highlights = {
  ["@tag.html"] = { link = "Statement" },
  ["@tag.attribute.html"] = { link = "Type" },
  ["@string.html"] = { link = "String" },
  Identifier = { fg = "#bb9af7" },
}

require("svim.utils.colorscheme").define_highlights("html", highlights, true, "onedarker", true)
