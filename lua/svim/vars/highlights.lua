local dashboard_highlights = require("svim.vars.dashboard").highlights

return {
  -- Cursor line & Line number
  CursorLine = { bg = "#2b2b2b" },
  CursorLineNr = { fg = "#1f85de" },

  -- Dashboard (Alpha) highlights
  AlphaHeader = dashboard_highlights.header,
  AlphaFooter = dashboard_highlights.footer,
  AlphaButtons = dashboard_highlights.buttons,
  AlphaShortcut = dashboard_highlights.shortcut,

  -- Autocompletion (nvim-cmp) kind highlights
  CmpItemKindCopilot = { fg = "#6cc644" },
  CmpItemKindTabnine = { fg = "#ca42f0" },
  CmpItemKindCrate = { fg = "#f64d00" },
  CmpItemKindEmoji = { fg = "#fde030" },
}
