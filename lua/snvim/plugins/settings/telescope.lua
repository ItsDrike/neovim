local m = require("snvim.utility.mappings")

m.keymap("n", "ff", "<cmd>Telescope find_files<CR>")
m.keymap("n", "fg", "<cmd>Telescope live_grep<CR>")
m.keymap("n", "fb", "<cmd>Telescope buffers<CR>")
m.keymap("n", "fh", "<cmd>Telescope help_tags<CR>")
m.keymap("n", "fgb", "<cmd>Telescope git_branches<CR>")
m.keymap("n", "fgc", "<cmd>Telescope git_commits<CR>")
m.keymap("n", "fgs", "<cmd>Telescope git_status<CR>")
