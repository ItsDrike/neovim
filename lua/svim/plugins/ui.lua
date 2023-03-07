return {
  -- noicer ui
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        -- Show progress messages from language servers doing analysis
        -- (See routes for how these are filtered)
        progress = {
          enabled = true,
        },
        hover = {
          enabled = true,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.utils.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        -- Don't show lsp progress messages containing "Diagnosing" word, these show up
        -- every time a buffer is updated, as the lang server reanalyzes the file, and
        -- are very frequent, making them annoying.
        {
          filter = { event = "lsp", kind = "progress", find = "Diagnosing" },
          opts = { skip = true },
        }
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    keys = {
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>unl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>unh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>una", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = { "i", "n", "s" } },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = { "i", "n", "s" } },
    },
  },

  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    init = function()
      -- If noice is installed, we don't need to override vim.notify,
      -- it does it for us already, and utilizes nvim-notify when needed.
      -- Otherwise, override vim.notify manually on VeryLazy event, requiring the plugin, hence also loading it
      local Util = require("svim.utils.plugins")
      if not Util.has("noice.nvim") then
        Util.on_very_lazy(function()
          vim.notify = require("notify")
        end)
      end
    end,
  },

  -- dashboard (on vim enter without file/dir param)
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
