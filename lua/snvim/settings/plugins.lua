local settings = require "snvim.utils.settings"

local M = {}

M.config = {
    { "wbthomason/packer.nvim" },           -- Let packer manage itself, so it gets updates
    { "Tastyep/structlog.nvim" },           -- Structured logging for nvim
}

return M
