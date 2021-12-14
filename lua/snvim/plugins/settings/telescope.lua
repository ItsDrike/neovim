local m = require("snvim.utility.mappings")

local prefix = "<cmd>lua require('telescope.builtin')."

m.keymap("n", "ff", prefix .. "find_files()<CR>")
m.keymap("n", "fg", prefix .. "live_grep()<CR>")
m.keymap("n", "fb", prefix .. "buffers()<CR>")
m.keymap("n", "fh", prefix .. "help_tags()<CR>")
m.keymap("n", "fgb", prefix .. "git_branches()<CR>")
m.keymap("n", "fgc", prefix .. "git_commits()<CR>")
m.keymap("n", "fgs", prefix .. "git_status()<CR>")
