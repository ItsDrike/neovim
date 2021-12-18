local cmp = require("cmp")
local luasnip = require("luasnip")


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
        ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
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
