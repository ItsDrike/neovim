-- This file contains some support functions used in the configuration files of
-- the individual providers
local vim = require("vim")
local util = require("lspconfig.util")
local path = util.path
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

    -- Try to find venv path with poetry if poetry.lock is present somewhere in
    -- the parents directory tree
    local poetry_match = lsp_utils.find_parent_with_name("poetry.lock", workspace)
    if poetry_match then
        local venv = vim.fn.trim(vim.fn.system("poetry env info --path"))
        if venv ~= "" then
            return venv
        end
    end

    -- Try to find venv path with pipenv if Pipfile is present somewhere in the
    -- parents directory three
    local pipenv_match = lsp_utils.find_parent_with_name("Pipfile", workspace)
    if pipenv_match then
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
        if parent then
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

-- Get path to the root directory of a python project. If we find a venv, get
-- root project path based on it, alternatively if we find one of certain
-- common files in some of the parent directories, use that parent directory.
-- If that also fails, try to obtain the root directory using git. If all of
-- the above still failed, just return the directory of given file.
-- @param fname string path to a file within a python project
function M.get_python_root_dir(fname)
    local venv_path = M.get_python_venv(fname)
    if venv_path then
        return path.dirname(venv_path)
    end

    local root_files = {
        "pyproject.toml",
        "Pipfile",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
    }
    local project_path = lsp_utils.find_parent_with_name(unpack(root_files), fname)
    if project_path then
        return project_path
    end

    local git_path = util.find_git_ancestor(fname)
    if git_path then
        return git_path
    end

    if path.is_file(fname) then
        return path.dirname(fname)
    else
        return fname
    end
end

return M
