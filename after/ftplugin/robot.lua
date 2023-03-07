-- Define highlights using LSP Semantic tokens from robotframework-lsp
-- (We can't use TreeSitter here, since robot files don't have any TreeSitter parser,
-- but since the lang server supports semantic tokens, we can use those for highlights)

local highlights = {
  ["@variable"] = { fg = "#9cdcfe" },
  ["@comment"] = { fg = "#6a9955" },
  ["@header"] = { fg = "#4ec9b0" },
  ["@setting"] = { fg = "#c177da" },
  ["@name"] = { fg = "#e1bd78" },
  ["@variableOperator"] = { fg = "#d4d4d4" },
  ["@settingsOperator"] = { fg = "#d4d4d4" },
  ["@keywordNameDefinition"] = { fg = "#dcdcaa" },
  ["@keywordNameCall"] = { fg = "#569cd6" },
  ["@control"] = { fg = "#c586c0" },
  ["@testCaseName"] = { fg = "#dcdcaa" },
  ["@parameterName"] = { fg = "#9cdcfe" },
  ["@argumentValue"] = { fg = "#ce9178" },
  ["@error"] = { fg = "#f44747" },
  ["@documentation"] = { fg = "#6a9955" },
}

for hl_group, val in pairs(highlights) do
  vim.api.nvim_set_hl(0, hl_group, val)
end
