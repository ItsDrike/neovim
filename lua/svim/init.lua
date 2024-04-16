local M = {}

-- Minimum required versions for this setup
M.neovim_version = "0.8"
M.lazy_version = ">=9.1.0"

M.plugin_spec = {
  { import = "svim.plugins"},
  { import = "svim.plugins.extra.wakatime" },
  { import = "svim.plugins.extra.indents" },
}

-- Entrypoint (called from init.lua)
function M.setup()
  M.ensure_nvim()

  local PluginLoader = require("svim.plugin-loader")
  PluginLoader.init()

  M.ensure_lazy()

  require("svim.utils.notify").lazy_notify()

  -- Load options here, before lazy setup
  -- This is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")

  PluginLoader.setup(M.plugin_spec)
  PluginLoader.ensure_plugins()

  -- Load configurations on VeryLazy if we didn't open any file to speed things up
  if vim.fn.argc(-1) == 0 then
    vim.api.nvim_create_autocmd("User", {
      group = require("svim.utils.autocmds").augroup("config_load"),
      pattern = "VeryLazy",
      callback = function()
        M.load("keymaps")
        M.load("abbreviations")
      end
    })
  else
    M.load("keymaps")
    M.load("abbreviations")
  end

  -- Autocmds need to be loaded immediately, because they include Colorscheme autocmd
  -- and VeryLazy runs after this, meaning we won't get our syntax overrides for the
  -- dashboard screen.
  M.load("autocmds")

  local colorscheme = require("svim.vars").colorscheme
  require("lazy.core.util").try(function()
    vim.cmd.colorscheme(colorscheme)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      require("lazy.core.util").error(msg)
      vim.cmd.colorscheme("habamax")
    end
  })
end

---@param name "autocmds" | "options" | "keymaps" | "abbreviations"
function M.load(name)
  local Util = require("lazy.core.util")
  local function _load(mod)
    Util.try(function()
      require(mod)
    end, {
        msg = "Failed loading " .. mod,
        on_error = function(msg)
          local modpath = require("lazy.core.cache").find(mod)
          if modpath then
            Util.error(msg)
          end
        end,
      })
  end

  _load("svim.config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: SVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd [[do VimResized]]
  end
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
