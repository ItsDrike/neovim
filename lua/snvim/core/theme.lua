local settings = require "snvim.utils.settings"

-- TODO: Change this to autocmd running on ColorScheme
-- after we set up a hook running after packer init

local config = settings.get_settings("theme")

vim.cmd("colorscheme " .. config.colorscheme)
