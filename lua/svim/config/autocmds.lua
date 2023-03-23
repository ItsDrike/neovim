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

-- Resize splits if window got changed
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Resize splits if window is resized",
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

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
