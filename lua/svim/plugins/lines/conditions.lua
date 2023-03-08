local M = {}

M.window_width_limit = 100

function M.buffer_not_empty()
  return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
end

function M.hide_in_width()
  return vim.o.columns > M.window_width_limit
end

return M
