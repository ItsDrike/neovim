-- This file is automatically loaded by lazyvim.plugins.config

local Autocmds = require("svim.utils.autocmds")
local augroup = Autocmds.augroup

-- Add some extra highlight groups
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = augroup("colorscheme"),
  callback = function()
    local highlights = require("svim.vars.highlights")
    for hl_group, val in pairs(highlights) do
      vim.api.nvim_set_hl(0, hl_group, val)
    end
  end
})
