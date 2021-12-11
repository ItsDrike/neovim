local vim = require("vim")
local fn = vim.fn

-- Load in our default plugin independant LSP settings.
-- These are loaded from here, because we don't need them if we aren't using
-- these plugins, which actually load in the LSP configurations and install the
-- individual language servers. However it is possible to configure nvim
-- without these plugins and so this config is separated from the plugin
-- config. for more info, check the comments in lsp/init.lua
require("snvim.lsp")


-- Configure nvim-cmp to respect LSP completions.
local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" }
    }
})

-- Load in the needed settigns for nvim-lsp-installer plugin.
-- This ensures automatic installation for the individual language servers.
local lsp_installer = require("nvim-lsp-installer")

-- Define some settings for the UI and installation path for the language
-- servers.
lsp_installer.settings({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        },
        keymaps = {
            toggle_server_expand = "<CR>",
            install_server = "i",
            update_server = "u",
            uninstall_server = "X",
        },
    },
    install_root_dir = fn.stdpath("data") ..  "/lsp_servers",
})

-- Define a table of requested language servers which should be automatically
-- installed.
--
-- NOTE: pylsp requires external installaion with
-- :PylspInstall pyls-flake8 pyls-mypy pyls-isort
local requested_servers = {
    "clangd", "cmake", "omnisharp",
    "cssls", "dockerls", "gopls", "html",
    "hls", "jsonls", "jdtls", "tsserver",
    "sumneko_lua", "pyright", "pylsp",
    "sqlls", "vimls", "yamlls"
}

-- Go through the requested servers and ensure installation
-- Once the servers are ready, run setup() on them. This setup is basically
-- running the lspconfig.server.setup() which means lspconfig is needed to do
-- this.
local lsp_setup = require("snvim.lsp.setup")
for _, requested_server in pairs(requested_servers) do
    lsp_setup.setup(requested_server)
end
