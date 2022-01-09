-- vim: ft=lua tw=80

stds.nvim = {
    globals = {
        "lvim",
    },
    read_globals = {
        "vim"
    }
}

std = "lua51+nvim"

ignore = {
    "212/_.*" -- Unused arugment, for vars with "_" prefix
}
