return {
  logo = {
    "░▒█▀▀▀█░▀█▀░█▀▀░█░░█░░█▀▀▄░█▀▀▄░▒█▄░▒█░▄░░░▄░░▀░░█▀▄▀█",
    "░░▀▀▀▄▄░░█░░█▀▀░█░░█░░█▄▄█░█▄▄▀░▒█▒█▒█░░█▄█░░░█▀░█░▀░█",
    "░▒█▄▄▄█░░▀░░▀▀▀░▀▀░▀▀░▀░░▀░▀░▀▀░▒█░░▀█░░░▀░░░▀▀▀░▀░░▒▀",
  },
  -- Amount of columns (characters) the logo takes up
  -- (This is hard-coded, since logo string is unicode, and lua counts bytes, not chars with string.len)
  logo_width = 54,
  -- splash_text can be a string, list of strings (multiple lines), or a function returning either
  ---@type function|string|table<string>
  splash_text = function()
    local possibilities = {
      -- {}, -- no splash is an option too, for the clean look
      {
        "Nothing to see here",
        "Move on ...",
      }, -- multiline splash
      "Denser than Emacs!",
      "Hello there",
      "90% bug free!",
      "Cooler than Spock!",
      "It's free software!",
      "Free as in freedom",
      "sqrt(-1) love you!",
      "Vim, the final frontier",
      "You're going too fast!",
      "Licensed under GPL v3: Glorious People's License",
      "Rule #1: it's never my fault",
    }
    math.randomseed(os.time())
    return possibilities[math.random(#possibilities)]
  end,
  highlights = {
    header = { fg = "blue" },
    footer = { fg = "gray" },
    buttons = { fg = "lightgray" },
    shortcut = { fg = "yellow" },
  }
}
