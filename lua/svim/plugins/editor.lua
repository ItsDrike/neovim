return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    depends = { "nui.nvim", "nvim-web-devicons" }, -- specified in utils spec
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("svim.utils.lsp").get_root() })
        end,
        desc = "Explorer NeoTree (root dir)"
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)"
      },
      { "<C-n>", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<C-S-n>", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    -- Automatically open NeoTree if nvim was opened on a directory
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },

  -- Highlight references of token under cursor
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- providers: provider used to get references in the buffer, ordered by priority
      providers = {
          'lsp',
          'treesitter',
          'regex',
      },
      delay = 200
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      -- Set the keybinds after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "]]", function()
            require("illuminate")["goto_next_reference"](false)
          end, { desc = "Next Reference", buffer = buffer })
          vim.keymap.set("n", "[[", function()
            require("illuminate")["goto_prev_reference"](false)
          end, { desc =  "Prev Reference", buffer = buffer })
        end,
      })
    end,
    keys = {
      { "]]", function() require("illuminate")["goto_next_reference"](false) end, desc = "Next Reference" },
      { "[[", function() require("illuminate")["goto_prev_reference"](false) end, desc = "Prev Reference" },
    },
  },
}
