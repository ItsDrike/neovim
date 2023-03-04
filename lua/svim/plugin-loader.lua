local Path = require("svim.utils.path")

local M = {}

---@class LazyConf
M.lazy_opts = {
  checker = { enabled = true }, -- automatically check for plugin updates
  install = {
    missing = true,
    colorscheme = { "habamax" },
  },
  defaults = {
    -- Only load plugins when they're needed
    -- (when they're lua requested, or when one of the lazy-loading handlers triggers)
    lazy = true,
    -- It's recommended to leave version=false for now, since not a lot of the plugins
    -- support versioning or have outdated releases, which may break your Neovim install.
    version = false, -- always install latest git commit
    --version = "*", -- try installing the latest stable version for plugins that support semver
  },
  ui = { border = "rounded" },
}

---Initialize the plugin manager (folke/lazy.nvim), bootstrap if needed
function M.init()
  local install_dir = Path.join_paths(Path.runtime_dir, "lazy", "lazy.nvim")

  if not Path.is_directory(install_dir) then
    print("Initializing first time setup")
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lay.nvim.git",
      install_dir,
    })
  end

  vim.opt.runtimepath:prepend(install_dir)
end

---Setup lazy (standalone, without installing plugins yet)
---@param plugins string|table
function M.setup(plugins)
  local lazy_available, Lazy = pcall(require, "lazy")
  if not lazy_available then
    vim.notify("Unable to run load plugins, lazy.nvim is not installed!", vim.log.levels.ERROR)
    error("Exiting")
  end

  local status_ok = xpcall(function()
    Lazy.setup(plugins, M.lazy_opts)
  end, debug.traceback)

  if not status_ok then
    vim.notify("Problems detected while loading plugin manager", vim.log.levels.ERROR)
    vim.notify(debug.traceback(), vim.log.levels.WARN)
    error("Exiting")
  end
end


---Install all plugins
function M.ensure_plugins()
  local status_ok, Lazy = pcall(require, "lazy")
  if not status_ok then
    vim.notify("Unable to load plugins, lazy.nvim is not installed!")
    error("Exiting")
  end

  Lazy.install({ wait = true })
end

return M
