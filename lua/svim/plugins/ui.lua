return {
  -- noicer ui
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "nui.nvim" }, -- specified in utils spec
    opts = {
      cmdline = {
        enabled = true, -- Enables Noice for cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. (change to `cmdline` for a classic cmdline at the bottom)
      },
      messages = {
        -- NOTE: if you enable messages, then cmdline is enabled automatically
        -- This is a current Neovim limitation.
        --
        -- NOTE: This tends to be very spammy without any filtering! While there is some
        -- filters defined in routes, you may want to adjust this and add some more, to
        -- suit your needs, or perhaps even disable messages all together.
        enabled = true, -- Enables Noice messages UI
        view = "notify", -- Default view for messages (set to mini for bottom right)
        view_error = "notify", -- View for errors
        view_warn = "notify", -- View for warnings
        view_history = "messages", -- View for :messages
        view_search = "virtualtext", -- View for search count messages (`false` to disable)
      },
      popupmenu = {
        enabled = true, -- Enables the Noice popupmenu UI
        ---@type 'nui'|'cmp'
        backend = "nui", -- backend to use to show regular cmdline completions
      },
      redirect = {
        view = "popup",
        filter = { event = "msg_show" },
      },
      notify = {
        -- Have noice override `vim.notify`.
        -- By default, noice will use nvim-notify anyway, if available
        -- causing same behavior as if nvim-notify was installed on it's own,
        -- with the benefit of having these stored in the history view.
        enabled = true,
        view = "notify",
      },
      lsp = {
        progress = {
          -- Show progress messages from language servers doing analysis
          --
          -- NOTE: While cool, this gets very distracting as some language servers produce very
          -- repetetive progress messages on every update (such as "Diagnosing..."). While these
          -- can be configured to get skipped in routes based on specific pattern of the message,
          -- every language server is different, and with some, it can be pretty hard to filter
          -- out.
          --
          -- If desired, there is an alternative implementation using vim.notify in plugins/lsp,
          -- which tries to avoid repetetive messages, but it's far from perfect and disabled
          -- by default.
          enabled = false,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30, -- frequency to update lsp progress message
          view = "mini",
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
          -- override the default lsp markdown formatter with Noice
          ["vim.lsp.utils.convert_input_to_markdown_lines"] = true,
          -- override the lsp markdown formatter with Noice
          ["vim.lsp.stylize_markdown"] = true,
          -- override cmp documentation with Noice (needs the other options to work)
          ["cmp.entry.get_documentation"] = false,
        },
      },
      routes = {
        -- HACK: Don't show messages like "ui.lua" line 36 of 46 --65%-- col 29
        -- This can probably be done via some neovim option, but I can't for the
        -- life of me figure out which with one, and well, this works.
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "line %d+ of %d+ %-%-%d+%%%-%- col %d+"
          },
          opts = { skip = true },
        },

        -- HACK: Don't show messages like "ui.lua" 46L, 1192B
        -- This can probably be done via some neovim option, but I can't for the
        -- life of me figure out which with one, and well, this works.
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = " %d+L, %d+B",
          },
          opts = { skip = true },
        },

        --  Messages with kind "" are unknown, (things like file was written, undo messages, ...),
        --  and we should generally avoid showing them in some custom view, as they can often
        --  get quite distracting, just use the default cmdline one
        {
          view = "mini",
          filter = {
            event = "msg_show",
            kind = "",
          },
        },

        -- Usi mini view for "Search hit BOTTOM/TOP" warning messages and
        -- pattern not found messages. No need for full notifications here.
        {
          view = "mini",
          filter = {
            event = "msg_show",
            kind = "wmsg",
            find = "search hit %u+, continuing at %u+",
          },
        },
        {
          view = "mini",
          filter = {
            event = "msg_show",
            kind = "emsg",
            find = "E486: Pattern not found: ",
          },
        },

        -- By default, noice skips msg_showmode messages, generally responsible for
        -- messages such as `--INSERT--`. However this message kind also handle macro
        -- messages, like `recording @q`, which we do want to see. Since we disable
        -- these mode messages (`:set noshowmode`), we can re-enable these messages,
        -- without causing too much annoyances.
        {
          view = "cmdline",
          filter = { event = "msg_showmode" },
        },

        -- Don't show lsp progress messages containing "Diagnosing" word, these show up
        -- every time a buffer is updated, as the lang server reanalyzes the file, and
        -- are very frequent, making them annoying.
        {
          filter = {
            event = "lsp",
            kind = "progress",
            find = "Diagnosing"
          },
          opts = { skip = true },
        },
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
        "<leader>ud",
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

  -- Improve all UI interfaces (overrides vim.ui)
    {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      -- Will be required on first UI vim.ui.input/vim.ui.select function call
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
}
