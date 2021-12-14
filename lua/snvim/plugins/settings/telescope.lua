local m = require("snvim.utility.mappings")

m.keymap("n", "ff", "<cmd>Telescope find_files<CR>")
m.keymap("n", "fg", "<cmd>Telescope live_grep<CR>")
m.keymap("n", "fb", "<cmd>Telescope buffers<CR>")
m.keymap("n", "fh", "<cmd>Telescope help_tags<CR>")
