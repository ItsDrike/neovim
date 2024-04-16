return {
  -- session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", version = "*", lazy = true },

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- ui components
  -- many plugins require this
  { "MunifTanjim/nui.nvim", lazy = true },

  -- icons
  -- many plugins require this
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
