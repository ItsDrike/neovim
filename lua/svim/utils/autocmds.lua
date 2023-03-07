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

---Wrapper around nvim_create_augroup, adding svim_ prefix, and clearing
function M.augroup(name)
  return vim.api.nvim_create_augroup("svim_" .. name, { clear = true })
end

return M
