local cmp = require("cmp")

local source_names = {
  buffer   = "Buf",
  nvim_lsp = "LSP",
  path     = 'Path',
  cmdline  = 'CMD',
}

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
    },
    experimental = {
        ghost_text = true,
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            -- Show LSP type/kind (function/class/...) with lspkind plugin
            local lspkind = require("lspkind")
            vim_item.kind = lspkind.presets.default[vim_item.kind]

            -- Show source of the completion
            local nm = source_names[entry.source.name]
            if nm then
                vim_item.menu = string.format("[%s]", nm)
            end

            -- Limit completion hint width
            local maxwidth = 50
            if #vim_item.abbr > maxwidth then
                vim_item.abbr = vim_item.abbr:sub(1, maxwidth) .. "..."
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
})

cmp.setup.cmdline('/', { sources = { name = 'buffer' } })
cmp.setup.cmdline(':', { sources = { name = 'cmdine' } })
