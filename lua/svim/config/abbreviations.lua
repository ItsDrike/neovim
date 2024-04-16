---Define an abbreviations
---@param mode "c"|"i" TODO: finish the rest
---@param input string
---@param result string
---@param reabbrev? boolean false by default
local function abbrev(mode, input, result, reabbrev)
  --HACK: There's no built-in lua API for defining abbreviations, do it through vim.cmd
  reabbrev = reabbrev or false

  local command
  if reabbrev then
    command = mode .. "abbrev"
  else
    command = mode .. "noreabbrev"
  end

  vim.cmd(command .. " " .. input .. " " .. result)
end

-- Invalid case abbreviations
abbrev("c", "Wq", "wq")
abbrev("c", "wQ", "wq")
abbrev("c", "WQ", "wq")
abbrev("c", "W", "w")
abbrev("c", "Q", "q")
abbrev("c", "W!", "w!")
abbrev("c", "Q!", "q!")
abbrev("c", "Qall", "qall")
abbrev("c", "Qall!", "qall!")
abbrev("c", "QALL", "qall")
abbrev("c", "QALL", "qall!")

-- Save file with sudo
abbrev("c", "w!!", "w !sudo tee >/dev/null %")
