local provider_utils = require("snvim.lsp.providers")

local opts = {
    root_dir = function (fname)
        return provider_utils.get_python_root_dir(fname)
    end,
    before_init = function(_, config)
        config.settings.python.pythonPath = provider_utils.get_python_bin(config.root_dir)
    end
}

return opts
