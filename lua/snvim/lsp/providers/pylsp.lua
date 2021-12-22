local provider_utils = require("snvim.lsp.providers")

local opts = {
    root_dir = function (fname)
        return provider_utils.get_python_root_dir(fname)
    end,
    settings = {
        pylsp = {
            plugins = {
                flake8 = { enabled = true },
                jedi_completion = { enabled = false },
                pycodestyle = { enabled = false },
                pydocstyle = { enabled = false },
                pyflakes = { enabled = false },
                pylint = { enabled = false },
                rope_completion = { enabled = false },
                yapf = { enabled = false }
            },
            configurationSources = { "flake8" },
        },
    }
}

return opts
