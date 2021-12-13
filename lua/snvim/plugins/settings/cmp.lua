local cmp = require("cmp")

cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
    },
})

cmp.setup.cmdline('/', { sources = { name = 'buffer' } })
cmp.setup.cmdline(':', { sources = { name = 'cmdine' } })
