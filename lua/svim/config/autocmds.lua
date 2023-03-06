-- This file is automatically loaded by lazyvim.plugins.config

local function augroup(name)
  return vim.api.nvim_create_augroup("svim_" .. name, { clear = true })
end

-- Add some extra highlight groups
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = augroup("svim_colorscheme"),
  callback = function()
    local highlights = require("svim.vars.highlights")
    for hl_group, val in pairs(highlights) do
      vim.api.nvim_set_hl(0, hl_group, val)
    end
  end
})
