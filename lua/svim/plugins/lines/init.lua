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
}
