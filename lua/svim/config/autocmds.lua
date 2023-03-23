-- This file is automatically loaded by lazyvim.plugins.config

local Autocmds = require("svim.utils.autocmds")
local augroup = Autocmds.augroup

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank( { higroup = "Search", timeout = 100 } )
  end,
  desc = "Highlight text on yank",
})

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
