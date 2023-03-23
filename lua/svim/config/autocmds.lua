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

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "floatterm",
    "lspinfo",
    "lir",
    "lsp-installer",
    "null-ls-info",
    "tsplayground",
    "spectre_panel",
    "startuptime",
    "DressingSelect",
    "Jaq",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>Close<CR>", { buffer = event.buf, silent = true })
  end,
  desc = "Close certain filetypes with q",
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
