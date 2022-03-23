local M = {}

M.config = {
    colorscheme = "codedark",
    show_cursor_line=true,
    show_line_numbers=true,
    show_relative_numbers=true,
    show_matching_brackets=true,
    enable_line_wrapping=true,
    vertical_scrolloff=5,
    horizontal_scrolloff=5,

    -- Make cursor line more noticable
    cursor_line_guibg = "#2b2b2b",
    cursor_line_ctermbg = "None",
    cursor_line_number_guifg = "#1f85de",
    cursor_line_number_ctermfg = "LightBlue",
}

return M
