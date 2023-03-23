local M = {}

---@param highlights table<string, table>
function M._set_local_highlights(highlights)
  local ns = vim.api.nvim_create_namespace("svim_local_highlights")

  for hl_group, val in pairs(highlights) do
    vim.api.nvim_set_hl(ns, hl_group, val)
  end

  -- Activate the highlights for this namespace
  vim.api.nvim_set_hl_ns(ns)
end

---@param highlights table<string, table>
function M._set_global_highlights(highlights)
  for hl_group, val in pairs(highlights) do
    vim.api.nvim_set_hl(0, hl_group, val)
  end
end

---@param name string Unique (with colorscheme) name for these highlights (suffix added to augroup)
---@param highlights table<string, table>
---@param local_only boolean Only define these aliases in a local namespace (only one can be active at a time)
---@param colorscheme? string What colorscheme should these highlights apply to (nil/"*" for all)
---@param now? boolean Also define the highlights immediately (if colorscheme matches), not just with autocommands (nil for false)
function M.define_highlights(name, highlights, local_only, colorscheme, now)
  colorscheme = colorscheme or "*"
  now = now or false

  local func
  if local_only then
    func = function() M._set_local_highlights(highlights) end
  else
    func = function() M._set_global_highlights(highlights) end
  end

  local augroup = require("svim.utils.autocmds").augroup("highlight_" .. (local_only and "local_" or "global_") .. colorscheme .. "_" .. name)
  vim.api.nvim_create_autocmd({ "ColorScheme" }, {
    group = augroup,
    pattern = colorscheme,
    callback = func,
  })

  if now and vim.g.colors_name == colorscheme then
    func()
  end
end

return M
