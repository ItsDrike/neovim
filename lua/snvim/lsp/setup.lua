-- Most of the functions in this file require lspconfig plugin to work
-- since it provides default configurations for the language servers.
local vim = require("vim")
local lsp_utils = require("snvim.lsp.utils")

local M = {}

-- Manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require("lspconfig")[server_name].manager.try_add_wrapper(bufnr)
end

-- Get default language server capabilities
-- if we have cmp-nvim-lsp plugin, it's capabilities will be included
function M.common_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
    end

    return capabilities
end

-- Get configuration for given language server (by name).
-- If we have lsp/providers/server_name file, we will use the config
-- table returned by it and extend the default configuration with it.
-- we can also extend this config with the config_override variable
function M.resolve_config(server_name, config_override)
    local config = {
        capabilities = M.common_capabilities()
    }

    -- Check for a configuration file in lsp/providers directory
    local has_custom_provider, custom_config = pcall(require, "snvim.lsp.providers." .. server_name)
    if has_custom_provider then
        config = vim.tbl_deep_extend("force", config, custom_config)
    end

    if config_override then
        config = vim.tbl_deep_extend("force", config, config_override)
    end

    return config
end

-- Setup a language server by providing a name. This uses nvim-lsp-installer and lspconfig plugins.
--@param server_name string name of the language server
--@param config_override table [optional] when available, it will extend the default configuration
function M.setup(server_name, config_override)
    vim.validate({ name = { server_name, "string" } })

    -- Don't perform another setup if the client is already active or loading
    if lsp_utils.is_server_active(server_name) or lsp_utils.is_server_configured(server_name) then
        return
    end

    local config = M.resolve_config(server_name, config_override)
    local servers = require("nvim-lsp-installer.servers")
    local server_available, requested_server = servers.get_server(server_name)

    -- If the server isn't available in nvim-lsp-installer servers,
    -- try to set it up purely with lspconfig setup call and start
    -- the server manually
    if not server_available then
        pcall(function()
            require("lspconfig")[server_name].setup(config)
            buf_try_add(server_name)
        end)
        return
    end

    local install_notification = false
    if not requested_server:is_installed() then
        requested_server:install()
        install_notification = true
    end

    requested_server:on_ready(function()
        if install_notification then
            vim.notify(string.format(
                "Instllation fomplete for [%s] language server",
                requested_server.name, vim.log.levels.INFO
            ))
        end
        requested_server:setup(config)
    end)
end


return M
