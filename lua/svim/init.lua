local M = {}

-- Minimum required versions for this setup
M.neovim_version = "0.8"
M.lazy_version = ">=9.1.0"

-- Entrypoint (called from init.lua)
function M.setup()
  M.ensure_nvim()

  local PluginLoader = require("svim.plugin-loader")
  PluginLoader.init()
  PluginLoader.setup("svim.plugins")

  M.ensure_lazy()

  PluginLoader.ensure_plugins()
end

function M.ensure_nvim()
  if vim.fn.has("nvim-" .. M.neovim_version) ~= 1 then
    vim.notify(
      "Please upgrade your Neovim base installation.\n"
      .. "StellarNvim requires v"
      .. M.neovim_version
      .. "+",
      vim.log.levels.ERROR
    )
    error("Exiting")
  end
end

function M.ensure_lazy()
  local status_ok, Semver = pcall(require, "lazy.manage.semver")
  if not status_ok then
    vim.notify("Lazy wasn't installed properly!", vim.log.levels.ERROR)
    error("Exiting")
  end

  local lazy_version = require("lazy.core.config").version or "0.0.0"

  if not Semver.range(M.lazy_version):matches(lazy_version) then
    vim.notify(
      "StellarNvim requires Lazy version: "
      .. M.lazy_version
      .. ", but version installed is "
      .. lazy_version
      .. ", run :Lazy update, and restart neovim")
    error("Exiting")
  end
end

return M
