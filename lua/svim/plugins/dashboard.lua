return {
  -- Alpha dashboard (shown on vim enter without file/dir param)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local dashboard_vars = require("svim.vars.dashboard")
      local icons = require("svim.vars.icons")

      -- Get random splash text to be shown
      local splash_text = dashboard_vars.splash_text
      if type(splash_text) == "function" then
        splash_text = splash_text()
      end
      if type(splash_text) == "string" then
        splash_text = { splash_text }
      end

      -- Show random splash text centered below the logo
      local logo_lines = vim.deepcopy(dashboard_vars.logo) -- don't modify original
      local logo_middle_cols = math.floor(dashboard_vars.logo_width / 2) -- middle of the logo col num
      for _, line in ipairs(splash_text) do
        local cols = math.max(logo_middle_cols - math.floor(line:len() / 2), 0)
        logo_lines[#logo_lines + 1] = string.rep(" ", cols) .. line
      end

      dashboard.section.header.val = logo_lines

      dashboard.section.buttons.val = {
        dashboard.button("f", icons.ui.FindFile .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", icons.ui.NewFile .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", icons.ui.History .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", icons.ui.FindText .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", icons.ui.Gear .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", icons.ui.Restore .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("l", icons.ui.Lazy .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", icons.ui.Quit .. " Quit", ":qa<CR>"),
      }

      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"

      -- Draw some blank lines above, to make the UI more centered
      dashboard.opts.layout[1].val = 5
      return dashboard
    end,
    config = function(_, dashboard)
      -- close lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val =  "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
  end,
  },
}
