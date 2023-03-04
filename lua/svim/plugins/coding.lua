return {
  -- auto pairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function(opts)
      require("mini.pairs").setup(opts)
    end
  },

  -- comments
  {
    "echasnovski/mini.comment",
    event = "InsertEnter",
    dependencies = { "nvim-ts-context-commentstring" }, -- specified in treesitter spec
    opts = {
      hooks = {
        pre = function()
          require("ts_context_commentstring.internal").update_commentstring({})
        end,
      },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)
    end,
  },
}
