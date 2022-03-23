local M = {}


-- Create autocommand groups based on the passed definitions
-- @param definitions table @Contains trigger, pattern and text.
-- The key will be used as a group name
-- @param buffer bool @Indicate if the autogroup should be local to the buffer
function M.define_augroups(definitions, buffer)
    for group_name, definition in pairs(definitions) do
        vim.cmd("augroup " .. group_name)

        if buffer then
            vim.cmd [[autocmd! * <buffer>]]
        else
            vim.cmd [[autocmd!]]
        end

        for _, def in pairs(definition) do
            local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
            vim.cmd(command)
        end

        vim.cmd "augroup END"
    end
end


-- Disable autocommand group if it exists.
-- This resets the autogroup to a new one with no autocmds. 
-- To reenable the group, we will need to redefine it.
-- (This is more reliable than trying to delete the autogroup itself)
-- @param name string @The autogroup name
function M.remove_autogroup(name)
    -- defer the fucntion in case the autocommand is still in-use
    vim.schedule(function()
        if vim.fn.exists("#" .. name) == 1 then
            vim.cmd("autogroup" .. name)
            vim.cmd "autocmd!"
            vim.cmd "aurogroup END"
        end
    end)
end


-- Define nvim keymapping
-- @param mode "n" | "i" | "v" | "x" | "s" | "o" | "c" | "l" | "t" | "!" | ""
-- @param shortcut string @The key to be mapped
-- @param command string
-- @param options passed to nvim_set_keymap, by default, we pass noremap=true, silent=true
function M.keymap(mode, shortcut, command, options)
    local opts = {noremap=true, silent=true}

    if options then opts = vim.tbl_extend("force", opts, options) end
    vim.api.nvim_set_keymap(mode, shortcut, command, opts)
end


-- Define an nvim abbreviation
-- @param mode "c" | "i" | ""
function M.abbrev(mode, input, result, reabbrev)
    -- TODO: nvim really needs something like vim.api.nvim_set_abbrev
    -- Assume noreabbrev unless specified otherwise
    reabbrev = reabbrev or false
    local command
    if reabbrev then
        command = mode .. "abbrev"
    else
        command = mode .. "noreabbrev"
    end
    vim.cmd(command .. " " .. input .. " " .. result)
end

return M
