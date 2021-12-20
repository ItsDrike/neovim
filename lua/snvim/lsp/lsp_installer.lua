-- Load in the needed settigns for nvim-lsp-installer plugin.
-- This ensures automatic installation for the individual language servers.
local lsp_installer = require("nvim-lsp-installer")
local lsp_setup = require("snvim.lsp.setup")
local vim = require("vim")

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
    install_root_dir = vim.fn.stdpath("data") ..  "/lsp_servers",
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
    "sqlls", "vimls", "yamlls", "rust_analyzer"
}

for _, requested_server in pairs(requested_servers) do
    lsp_setup.setup(requested_server)
end
