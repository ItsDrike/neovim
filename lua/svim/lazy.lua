local M = {}

function M.bootstrap_lazy()
  -- Bootstrap folke/lazy.nvim (plugin manager)
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    -- stylua: ignore
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  end
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
end

function M.setup_lazy()
  require("lazy").setup({
    -- Load all files in plugins/ directory
    spec = { { import = "svim.plugins" } },
    defaults = {
      -- Only load plugins when they're needed
      -- (when they're lua requested, or when one of the lazy-loading handlers triggers)
      lazy = true,
      -- It's recommended to leave version=false for now, since not a lot of the plugins
      -- support versioning or have outdated releases, which may break your Neovim install.
      version = false, -- always install latest git commit
      --version = "*", -- try installing the latest stable version for plugins that support semver
    },
    checker = { enabled = true }, -- automatically check for plugin updates
  })
end

return M
