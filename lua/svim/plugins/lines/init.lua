local Icons = require("svim.vars.icons")

return {
  -- bufferline (show opened buffers on top)
  {
    "akinsho/bufferline.nvim",
    event = "VimEnter",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        diagnostics_indicator = function(_, _, diag)
          local ret = (diag.error and Icons.diagnostics.Error .. diag.error .. " " or "")
            .. (diag.warning and Icons.diagnostics.Warning .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- LSP symbol navigation for lualine/winbar
  {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
    init = function()
      vim.g.navic_silence = true
      require("svim.utils.lsp").on_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, buffer)
        end
      end)
    end,
    opts = function()
      local kind_icons_spaced = {}
      for name, icon in pairs(Icons.kind) do
        kind_icons_spaced[name] = icon .. " "
      end

      return {
        separator = " " .. Icons.ui.ChevronRight .. " ",
        highlight = true,
        depth_limit = 5,
        depth_limit_indicator = "..",
        icons = kind_icons_spaced,
      }
    end,
    config = function(_, opts)
      require("svim.plugins.lines.navic").create_winbar()
      require("nvim-navic").setup(opts)
    end
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    opts = function()
      local components = require("svim.plugins.lines.components")
      return {
        style = "default",
        options = {
          theme = "auto",
          globalstatus = true,
          icons_enabled = Icons.enabled,
          component_separators = {
            left = "", -- Icons.ui.DividerRight
            right = "", -- Icons.ui.DividerLeft
          },
          section_separators = {
            left = "", -- Icons.ui.DividerRight
            right = "", -- Icons.ui.DividerLeft
          },
          disabled_filetypes = {
            statusline = {
              "alpha", -- Don't show status line in (alpha) dashboard
            }
          },
        },
        sections = {
          lualine_a = { components.mode },
          lualine_b = { components.branch },
          lualine_c = { components.diff, components.python_env },
          lualine_x = {
            components.plugins,
            components.diagnostics,
            components.treesitter_missing,
            components.lsp,
            components.spaces,
            components.filetype,
          },
          lualine_y = { components.progress },
          lualine_z = { components.location },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { components.filename },
          lualine_x = { components.filetype },
          lualine_y = {},
          lualine_z = { components.location },
        },
        -- If current filetype is in this list, inactive statusline is shown instead
        ignore_focus = {},
        -- Don't use lualine for tabline, we have bufferline
        tabline = {},
        extensions = { "neo-tree" },
      }
    end,
  }
}
