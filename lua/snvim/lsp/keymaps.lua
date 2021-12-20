-- This file sets up key bindings for LSP interactions. By default,
-- it will always set up keybinds with pure nvim's LSP, however if
-- telescope plugin is found, the it will be used for certain keymaps
-- instead, similarely, if lsp_signature plugin is found, some additional
-- keybinds may be added/overrided.
--
-- See `:help vim.lsp.*` for documentation on any of the below mapped functions
local m = require("snvim.utility.mappings")

-- Check if certain plugins are installed, if so, they should be used
-- to define some mappings
local telescope_installed, _ = pcall(require, "telescope")
local lsp_signature_installed, _ = pcall(require, "lsp_signature")

-- We usually always use the same prefixes, so just define them here
local lua_prefix = "<cmd>lua "
local lsp_prefix = lua_prefix .. "vim.lsp.buf."
local diagnostic_prefix = lua_prefix .. "vim.diagnostic."
local telescope_prefix = lua_prefix .. "require('telescope.builtin')."
local telescope_cursor_theme = "require('telescope.themes').get_cursor()"

-- Lookups
m.keymap("n", "gd", lsp_prefix .. "definition()<CR>")
m.keymap("n", "gD", lsp_prefix .. "declaration()<cr>")
m.keymap("n", "gr", lsp_prefix .. "references()<CR>")
m.keymap("n", "gi", lsp_prefix .. "implementation()<CR>")
m.keymap("n", "gt", lsp_prefix .. "type_definition()<CR>")

if telescope_installed then
    m.keymap("n", "gd", telescope_prefix .. "lsp_definitions()<cr>")
    m.keymap("n", "gr", telescope_prefix .. "lsp_references()<cr>")
    m.keymap("n", "gi", telescope_prefix .. "lsp_implementations()<cr>")
    m.keymap("n", "gt", telescope_prefix .. "lsp_type_definitions()<cr>")
end

-- Formatting
m.keymap("n", "<leader>gf", lsp_prefix .. "formatting()<cr>")
m.keymap("v", "<leader>gf", lsp_prefix .. "range_formatting()<cr>")

-- Hover info
m.keymap("n", "<C-k>", lsp_prefix .. "signature_help()<CR>")
m.keymap("n", "M", lsp_prefix .. "hover()<CR>")

if lsp_signature_installed then
    m.keymap("n", "<C-M>", lua_prefix .. "require('lsp_signature').signature()<cr>")
end

-- Diagnostics
m.keymap("n", "[g", diagnostic_prefix .. "goto_prev()<cr>")
m.keymap("n", "]g", diagnostic_prefix .. "goto_next()<cr>")
m.keymap("n", "ge", diagnostic_prefix .. "open_float(nil, { scope = 'line', })<cr>")

if telescope_installed then
    m.keymap("n", "<leader>ge", telescope_prefix .. "diagnostics()<cr>")
end

-- LSP Workspace
m.keymap("n", "<leader>wa", lsp_prefix .. "add_workspace_folder()<cr>")
m.keymap("n", "<leader>wr", lsp_prefix .. "remove_workspace_folder()<cr>")
m.keymap("n", "<leader>wl", lua_prefix .. "print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>")

--Actions
m.keymap("n", "<leader>ga", lsp_prefix .. "code_action()<cr>")
m.keymap("v", "<leader>ga", lsp_prefix .. "range_code_action()<cr>")
if telescope_installed then
    m.keymap("n", "<leader>ga", telescope_prefix .. "lsp_code_actions(" .. telescope_cursor_theme .. ")<cr>")
    m.keymap("v", "<leader>ga", telescope_prefix .. "lsp_range_code_actions(" .. telescope_cursor_theme .. ")<cr>")
end

-- Use custom implementation for renaming all references
m.keymap("n", "gn", lua_prefix .. "require('snvim.lsp.rename').rename()<cr>")
