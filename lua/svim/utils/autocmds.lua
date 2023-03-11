local M = {}

---Clean autocommand in a group if it exists
---This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds({ group = name })
    end)
  end)
end

---Wrapper around nvim_create_augroup, adding svim_ prefix
---@param name string
---@param opts? table If no opts are passed, { clear = true } is used
---@return integer id of the created group
function M.augroup(name, opts)
  opts = opts or { clear = true }
  return vim.api.nvim_create_augroup("svim_" .. name, opts)
end

return M
