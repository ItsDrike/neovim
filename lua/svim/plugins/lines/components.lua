local Icons = require("svim.vars.icons")
local Plugin = require("svim.utils.plugins")
local Conditions = require("svim.plugins.lines.conditions")

---Get a list of all registered null-ls roviders sorted into their methods
---@return string[]
local function _list_null_ls_providers(filetype)
  local mason_null_ls = require("mason-null-ls")
  local null_sources = require("null-ls.sources")

  local all_ft_sources = mason_null_ls.get_available_sources({ filetype = filetype })
  local available_sources = null_sources.get_available(filetype)

  ---@type string[]
  local registered = {}
  for _, source in ipairs(available_sources) do
    if vim.tbl_contains(all_ft_sources, source.name) then
      table.insert(registered, source.name)
    end
  end

  return registered
end


return {
  -- We don't need to see NORMAL/INSERT/...
  -- just show a target icon here, which will get colored
  -- besed on the current mode anyway
  mode = {
    function()
      return " " .. Icons.ui.Target .. " "
    end,
    padding = { left = 0, right = 0 },
    color = {},
    cond = nil,
  },
  branch = {
    Plugin.has("gitsigns.nvim") and "b:gitsigns_head" or "branch",
    icon = "%#SLGitIcon#" .. Icons.git.Branch .. "%*" .. "%#SLBranchName#",
    color = { gui = "bold" },
  },
  filename = {
    "filename",
    color = {},
    cond = nil,
  },
  diff = {
    "diff",
    source = function()
      ---@diagnostic disable-next-line: undefined-field
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end,
    symbols = {
      added = Icons.git.LineAdded .. " ", -- "+",
      modified = Icons.git.LineModified .. " ", -- "~",
      removed = Icons.git.LineRemoved .. " ", -- "-",
    },
    padding = { left = 2, right = 1 },
    diff_color = {
      added = { fg = "#98be65" },
      modified = { fg = "#ecbe7b" },
      removed = { fg = "#ec5f67" },
    },
  },
  python_env = {
    function()
      if vim.bo.filetype == "python" then
        local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
        if venv then
          -- Cleanup the venv path
          if string.find(venv, "/") then
            local final_venv = venv
            for w in venv:gmatch("([^/]+)") do
              final_venv = w
            end
            venv = final_venv
          end

          local icons = require("nvim-web-devicons")
          local py_icon, _ = icons.get_icon(".py")
          return string.format(" " .. py_icon .. " (%s)", venv)
        end
      end
      return ""
    end,
    color = { fg = "green" },
    cond = Conditions.hide_in_width,
  },
  diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = {
      error = Icons.diagnostics.BoldError .. " ",
      warn = Icons.diagnostics.BoldWarning .. " ",
      info = Icons.diagnostics.BoldInformation .. " ",
      hint = Icons.diagnostics.BoldHint .. " ",
    },
    -- cond = Conditions.hide_in_width,
  },
  lsp = {
    function(msg)
      msg = msg or "LS Inactive"
      local buf_clients = vim.lsp.get_active_clients()
      if next(buf_clients) == nil then
        if type(msg) == "boolean" or #msg == 0 then
          return "LS Inactive"
        end
        return msg
      end

      local buf_client_names = {}
      local copilot_active = false

      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" and client.name ~= "copilot" then
          table.insert(buf_client_names, client.name)
        end

        if client.name == "copilot" then
          copilot_active = true
        end
      end

      if Plugin.has("null-ls.nvim") then
        local null_servers = _list_null_ls_providers(vim.bo.filetype)
        vim.list_extend(buf_client_names, null_servers)
      end

      local unique_client_names = vim.fn.uniq(buf_client_names)
      local language_servers = "[" .. table.concat(unique_client_names, ", ") .. "]"

      if copilot_active then
        language_servers = language_servers .. "%#SLCopilot#" .. " " .. Icons.git.Octoface .. "%*"
      end

      return language_servers
    end,
    color = "SLLangServers",
    cond = Conditions.hide_in_width,
  },
  spaces = {
    function()
      local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
      return Icons.ui.Tab .. " " .. shiftwidth
    end,
    padding = 1,
    cond = Conditions.hide_in_width,
  },
  filetype = { "filetype", padding = { left = 1, right = 1 } },
  location = { "location" },
  progress = {
    "progress",
    fmt = function()
      return "%P/%L"
    end,
    color = {},
  },
  treesitter = {
    function()
      return Icons.ui.Tree
    end,
    color = function()
      local buf = vim.api.nvim_get_current_buf()
      local ts = vim.treesitter.highlighter.active[buf]
      return { fg = ts and not vim.tbl_isempty(ts) and "green" or "red" }
    end,
    cond = Conditions.hide_in_width,
  },
  treesitter_missing = {
    function()
      return Icons.ui.Tree
    end,
    color = { fg = "red" },
    cond = function()
      if not Conditions.hide_in_width() then
        return true
      end

      local buf = vim.api.nvim_get_current_buf()
      if vim.treesitter.highlighter.active[buf] then
        return false
      end
      return true
    end,
  },
  encoding = {
    "o:encoding",
    fmt = string.upper,
    cond = Conditions.hide_in_width,
  },
  scrollbar = {
    function()
      local current_line = vim.fn.line "."
      local total_lines = vim.fn.line "$"
      local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return chars[index]
    end,
    padding = { left = 0, right = 0 },
    color = "SLProgress",
  },
}
