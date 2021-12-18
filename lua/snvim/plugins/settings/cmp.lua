local cmp = require("cmp")
local luasnip = require("luasnip")
local vim = require("vim")


local cmp_settings = {
    kind_icons = {
        Class = " ",
        Color = " ",
        Constant = "ﲀ ",
        Constructor = " ",
        Enum = "練",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = "",
        Folder = " ",
        Function = " ",
        Interface = "ﰮ ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Operator = "",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = "塞",
        Value = " ",
        Variable = " ",
    },
    source_names = {
        buffer    = "Buf",
        nvim_lsp  = "LSP",
        path      = "Path",
        cmdline   = "CMD",
        luasnip   = "Snippet",
    },
    duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
    },
    duplicates_default = 0,
    max_completion_width = 30,
}

-- when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it's jumpable
-- @param dir number 1 for forward, -1 for backwards; defaults to 1
-- @return boolean true if a jumpable field is found while inside a snippet
local function jumpable(dir)
    local win_get_cursor = vim.api.nvim_win_get_cursor
    local get_current_buf = vim.api.nvim_get_current_buf

    local function inside_snippet()
        -- for outdated versions of luasnip
        if not luasnip.session.current_nodes then
            return false
        end

        local node = luasnip.session.current_nodes[get_current_buf()]
        if not node then
            return false
        end

        local snip_begin_pos, snip_end_pos = node.parent.snippet.mark:pos_begin_end()
        local pos = win_get_cursor(0)
        pos[1] = pos[1] - 1  -- Luasnip is 0-based, not 1-based like nvim rows
        return pos[1] >= snip_begin_pos[1] and pos[1] <= snip_end_pos[1]
    end

    -- sets the current buffer's luasnip to the one neareast the cursor
    -- @return boolean true if a node is found, false otherwise
    local function seek_luasnip_cursor_node()
        -- for outdated versions of luasnip
        if not luasnip.session.current_nodes then
            return false
        end

        local pos = win_get_cursor(0)
        pos[1] = pos[1] - 1  --Luasnip is 0-based, not 1-based like nvim rows
        local node = luasnip.session.current_nodes[get_current_buf()]
        if not node then
            return false
        end

        local snippet = node.parent.snippet
        local exit_node = snippet.insert_nodes[0]

        -- exit early if we're past the exit node
        if exit_node then
            local exit_pos_end = exit_node.mark:pos_end()
            if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil
                return false
            end
        end

        node = snippet.inner_first:jump_into(1, true)
        while node ~= nil and node.next ~= nil and node ~= snippet do
            local n_next = node.next
            local next_pos = n_next and n_next.mark:pos_begin()
            local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
                or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

            -- Past unmarked exit node, exit early
            if n_next == nil or n_next == snippet.next then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil
                return false
            end

            if candidate then
                luasnip.session.current_nodes[get_current_buf()] = node
                return true
            end

            local ok
            ok, node = pcall(node.jump_from, node, 1, true) -- no move until last stop
            if not ok then
                snippet:remove_from_jumplist()
                luasnip.session.current_nodes[get_current_buf()] = nil
                return false
            end
        end

        -- No candidate, but have an exit node
        if exit_node then
            luasnip.session.current_nodes[get_current_buf()] = snippet
            return true
        end

        -- No exit node, exit from snippet
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil
        return false
    end

    if dir == -1 then
        return inside_snippet() and luasnip.jumpable(-1)
    else
        return inside_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable()
    end
end

-- This function handles tab mapping for cmp. When we can, it selects next/previous item,
-- if not, we try to run luasnip exmpand, if that's also not available, we try to jump
-- with luasnip, alternatively we fallback.
-- @param dir number 1 for forward, -1 for backwards; defaults to 1
-- @param select_opts options passed to cmp.select_next/prev_item
-- @param fallback fallback function passed from cmp.mapping
local function interactive_tab(dir, select_opts, fallback)
    local select_item
    if dir == -1 then
        select_item = cmp.select_prev_item
    else
        dir = 1
        select_item = cmp.select_next_item
    end
    if cmp.visible() then
        select_item(select_opts)
    elseif luasnip.expandable() then
        luasnip.expand()
    elseif jumpable() then
        luasnip.jump(dir)
    else
        fallback()
    end
end

-- This function handles <CR> mapping for cmp. When we just confirmed a snippet
-- completion which has a jump position, jump to it. If not, just confirm and end,
-- Alternatively, check if we're already in a snippet and we can jump.
-- If neither, fallback.
-- @param confirm_opts options passed to cmp.confirm
-- @fallback fallback function passed from cmp.mapping
local function interactive_cr(confirm_opts, fallback)
    if cmp.visible() and cmp.confirm(confirm_opts) then
        if jumpable() then luasnip.jump(1) end
        return
    end
    if jumpable() and luasnip.jump(1) then return end
    fallback()
end


cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
        { name = "luasnip" },
    },
    experimental = {
        ghost_text = true,
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            -- Show kind icon (function/class/...)
            vim_item.kind = cmp_settings.kind_icons[vim_item.kind]
            -- Show source of the completion (lsp/buffer/path/snippet/...)
            local nm = cmp_settings.source_names[entry.source.name]
            if nm then
                vim_item.menu = string.format("[%s]", nm)
            end
            -- Enable duplicates? (competion recommendations with same name)
            vim_item.dup = cmp_settings.duplicates[entry.source.name] or cmp_settings.duplicates_default
            -- Limit completion hint width
            if #vim_item.abbr > cmp_settings.max_completion_width then
                vim_item.abbr = vim_item.abbr:sub(1, cmp_settings.max_completion_width) .. "..."
            end
            return vim_item
        end,
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping(function (fallback)
            return interactive_tab(1, { behavior = cmp.SelectBehavior.Insert }, fallback)
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function (fallback)
            return interactive_tab(-1, { behavior = cmp.SelectBehavior.Insert }, fallback)
        end, { "i", "s" }),
        ['<CR>'] = cmp.mapping(function (fallback)
            return interactive_cr({ behavior = cmp.ConfirmBehavior.Replace, select = false }, fallback)
        end),
    },
    snippet = {
        expand = function(args)
            -- Support snippets with LusSnip snippet engine plugin
            luasnip.lsp_expand(args.body)
        end
    },
})

cmp.setup.cmdline('/', { sources = { name = 'buffer' } })
cmp.setup.cmdline(':', { sources = { name = 'cmdine' } })
