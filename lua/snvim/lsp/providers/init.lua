-- This file contains some support functions used in the configuration files of
-- the individual providers
local vim = require("vim")
local path = require("lspconfig.util").path
local lsp_utils = require("snvim.lsp.utils")

local M = {}

-- Try to obtain python virtual environemnt path.
-- @param workspace string root workspace path. (Defaults to %:p:h)
-- @returns optional string path to virtual environment, nil if not found.
function M.get_python_venv(workspace)
    if workspace == nil then
        workspace = vim.fn.expand("%:p:h")
    end

    -- Try to use an activated virtual environment
    -- Most virtual environemnt utilities will set $VIRTUAL_ENV env variable
    if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV
    end

    -- Try to find venv path with poetry if poetry.lock is present
    local poetry_match = vim.fn.glob(path.join(workspace, "poetry.lock"))
    if poetry_match ~= "" then
        local venv = vim.fn.trim(vim.fn.system("poetry env info --path"))
        if venv ~= "" then
            return venv
        end
    end

    -- Try to find venv path with pipenv if Pipfile is present
    local pipenv_match = vim.fn.glob(path.join(workspace, "Pipfile"))
    if pipenv_match ~= "" then
        local venv = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipenv_match .. " pipenv --venv"))
        if venv ~= "" then
            return venv
        end
    end

    -- Check common directories used to store virtual environments
    for _, dirname in ipairs({'.venv', '.env', 'venv', 'env', 'ENV'}) do
        -- In case we didn't start nvim at the project's root, find the
        -- closest virtual env directory following parent dirts
        local parent = lsp_utils.find_parent_with_name(dirname, workspace)
        if parent ~= "" then
            return path.join(parent, dirname)
        end
    end
    return nil
end

--- Get path to python binary, if virtual environment path was found, use it,
-- if not, fall back to global system python
function M.get_python_bin(workspace)
    local venv_path = require("snvim.lsp.providers").get_python_venv(workspace)
    if  venv_path then
        -- Return the python binary within the venv
        return path.join(venv_path, "bin", "python")
    else
        -- Fallback to system python
        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    end
end

return M
