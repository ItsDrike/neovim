-- This file is automatically loaded by lazyvim.plugins.config

-- Add some extra highlight groups
for _, highlight_conf in ipairs(require("svim.vars.highlights")) do
  require("svim.utils.colorscheme").define_highlights(
    "main",
    highlight_conf.highlights,
    false,
    highlight_conf.colorscheme,
    false
  )
end
