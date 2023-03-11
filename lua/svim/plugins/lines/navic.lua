local icons = require("svim.vars.icons")

local M = {}

function M.get_filename()
  local filename = vim.fn.expand("%:t")
  local extension = vim.fn.expand("%:e")

  if filename == nil or filename == "" then
    return nil
  end

  local file_icon, hl_group
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  if devicons_ok then
    file_icon, hl_group = devicons.get_icon(filename, extension, { default = true })

    if file_icon == nil or file_icon == "" then
      file_icon = icons.kind.File
    end
  else
    file_icon = ""
    hl_group = "Normal"
  end

  local buf_ft = vim.bo.filetype

  if buf_ft == "dapui_breakpoints" then
    file_icon = icons.ui.Bug
  elseif buf_ft == "dapui_stacks" then
    file_icon = icons.ui.Stacks
  elseif buf_ft == "dapui_scopes" then
    file_icon = icons.ui.Scopes
  elseif buf_ft == "dapui_watches" then
    file_icon = icons.ui.Watches
  elseif buf_ft == "dapui_console" then
    file_icon = icons.ui.DebugConsole
  end

  return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#Winbar#" .. filename .. "%*"
end

function M.get_navic_location()
  local navic_ok, navic = pcall(require, "nvim-navic")
  if not navic_ok then
    return ""
  end

  if not navic.is_available() then
    return ""
  end

  local location_ok, location = pcall(navic.get_location, {})
  if not location_ok then
    return ""
  end

  if location == "error" then
    return ""
  end

  if location == nil or location == "" then
    return ""
  end

  return "%#NavicSeparator#" .. icons.ui.ChevronRight .. "%* " .. location
end

function M.add_winbar()
  local value = M.get_filename()
  if value == nil or value == "" then
    return
  end

  -- TODO: Consider not showing the filename if bufferline.nvim is visible

  local location_added = false
  local navic_location = M.get_navic_location()
  if navic_location ~= nil and navic_location ~= "" then
    location_added = true
  end
  value = value .. " " .. navic_location

  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, "mod")
  if status_ok and buf_option then
    local mod = "%#LspCodeLens#" .. icons.ui.Circle .. "%*"
    if location_added then
      value = value .. " " .. mod
    else
      value = value .. mod
    end
  end

  local num_tabs = #vim.api.nvim_list_tabpages()

  if num_tabs > 1 and value ~= nil and value ~= "" then
    local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
    value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
  end

  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

function M.create_winbar()
  vim.api.nvim_create_autocmd({
    "CursorHoldI",
    "CursorHold",
    "BufWinEnter",
    "BufFilePost",
    "InsertEnter",
    "BufWritePost",
    "TabClosed",
    "TabEnter",
  }, {
    group = require("svim.utils.autocmds").augroup("winbar"),
    callback = function()
      local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
      if not status_ok then
          require("svim.plugins.lines.navic").add_winbar()
      end
    end,
  })
end

return M
