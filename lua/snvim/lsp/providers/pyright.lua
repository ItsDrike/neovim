local vim = require("vim")
local path = require("lspconfig.util").path

local function get_python_path(workspace)
    local pybin = function(venv_path)
        return path.join(venv_path, "bin", "python")
    end

    -- Try to use an activated virtual environment
    -- Most virtual environemnt utilities will set $VIRTUAL_ENV env variable
    if vim.env.VIRTUAL_ENV then
        return pybin(vim.env.VIRTUAL_ENV)
    end

    -- Try to find venv path with poetry if poetry.lock is present
    local poetry_match = vim.fn.glob(path.join(workspace, "poetry.lock"))
    if poetry_match ~= "" then
        local venv = vim.fn.trim(vim.fn.system("poetry env info --path"))
        if venv ~= "" then
            return pybin(venv)
        end
    end

    -- Try to find venv path with pipenv if Pipfile is present
    local pipenv_match = vim.fn.glob(path.join(workspace, "Pipfile"))
    if pipenv_match ~= "" then
        local venv = vim.fn.trim(vim.fn.system("PIPENV_PIPFILE=" .. pipenv_match .. " pipenv --venv"))
        if venv ~= "" then
            return pybin(venv)
        end
    end

    -- Check common directories used to store virtual environments
    for _, dirname in ipairs({'.venv', '.env', 'venv', 'env', 'ENV'}) do
        local venv = vim.fn.glob(path.join(workspace, dirname))
        if venv ~= "" then
            return pybin(venv)
        end
    end

    -- Fallback to system python
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

local opts = {
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path(config.root_dir)
    end
}

return opts
