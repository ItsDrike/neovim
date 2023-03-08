local dashboard_highlights = require("svim.vars.dashboard").highlights

local statusline_hl = vim.api.nvim_get_hl_by_name("StatusLine", true)
local cursorline_hl = vim.api.nvim_get_hl_by_name("CursorLine", true)
local normal_hl = vim.api.nvim_get_hl_by_name("Normal", true)

return {
  -- Cursor line & Line number
  CursorLine = { bg = "#2b2b2b" },
  CursorLineNr = { fg = "#1f85de" },

  -- Dashboard (Alpha) highlights
  AlphaHeader = dashboard_highlights.header,
  AlphaFooter = dashboard_highlights.footer,
  AlphaButtons = dashboard_highlights.buttons,
  AlphaShortcut = dashboard_highlights.shortcut,

  -- Status Line
  SLCopilot = { fg = "#6cc644", bg = statusline_hl.background },
  SLGitIcon = { fg = "#e8ab53", bg = cursorline_hl.background },
  SLBranchName = { fg = normal_hl.foreground, bg = cursorline_hl.background },
  SLSeparator = { fg = cursorline_hl.background, bg = statusline_hl.background },
  SLLangServers = { fg = normal_hl.foreground, bg = cursorline_hl.background, bold = false },

  -- Autocompletion (nvim-cmp) kind highlights
  CmpItemKindCopilot = { fg = "#6cc644" },
  CmpItemKindTabnine = { fg = "#ca42f0" },
  CmpItemKindCrate = { fg = "#f64d00" },
  CmpItemKindEmoji = { fg = "#fde030" },

  -- LSP Semantic Tokens
  ["@parameter"] = { fg = "#ff9060" },
}
