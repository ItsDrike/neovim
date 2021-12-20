local vim = require("vim")
local fn = vim.fn

local plugin_directory = fn.stdpath("config") .. "/lua/snvim/plugins/settings"

-- Return the line (string) to be executed with lua that loads in given plugin file.
-- This is useful for the `config` or `setup` parameters of packer's use to source
-- both `.vim` and `.lua` files.
-- Expects a `plugin_file` which is a relative path from the `plugin_directory` folder.
local function get_plugin_file(plugin_file)
    local source_line = string.format("source %s/%s", plugin_directory, plugin_file)
    return string.format("vim.fn.execute('%s')", source_line)
end


-- Define packer plugins
-- The individual tables will get passed into the packer's use function
local plugin_list = {
    { "dhruvasagar/vim-table-mode" },       -- Easy way to construct markdown tables
    { "wakatime/vim-wakatime" },            -- Track time spent coding
    { "mhinz/vim-startify" },               -- Nice startup screen for vim when started withotu file/dir
    { "dbeniamine/cheat.sh-vim" },          -- Quick interaction with cheat.sh cheatsheets
    {
        "vimwiki/vimwiki",                  -- Wiki pages for vim
        config = get_plugin_file("vimwiki.lua"),
    },
    {
        "tpope/vim-commentary",             -- Adds ability to comment out sections of files
        config = get_plugin_file("commentary.lua"),
    },
    {
        "tomasiser/vim-code-dark",          -- Vim theme inspired by vscode's Dark+
        config = get_plugin_file("vim-code-dark.lua"),
    },
    {
        "L3MON4D3/LuaSnip",                 -- Support for snippets
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
        requires = { "rafamadriz/friendly-snippets" }
    },
    {
        "lewis6991/gitsigns.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = get_plugin_file("gitsigns.lua"),
    },
    {
        "nvim-treesitter/nvim-treesitter",  -- AST language analysis providing semantic highlighting
        config = get_plugin_file("treesitter.lua"),
        run = ":TSUpdate",
        requires = { "nvim-treesitter/playground", opt = true },
    },
    {
        "vim-airline/vim-airline",          -- Status line
        config = get_plugin_file("airline.lua"),
        requires = {
            { "vim-airline/vim-airline-themes" },
            { "ryanoasis/vim-devicons" },
        },
    },
    -- TODO: Consider changing this to nvim-tree
    {
        "preservim/nerdtree",               -- File tree
        config = get_plugin_file("nerdtree.lua"),
        requires = {
            { "Xuyuanp/nerdtree-git-plugin" },
            { "tiagofumo/vim-nerdtree-syntax-highlight" },
            { "ryanoasis/vim-devicons" },
        },
    },
    {
        "mfussenegger/nvim-dap",            -- Support for the debugging within vim
        config = get_plugin_file("nvim-dap.lua"),
        requires = { "mfussenegger/nvim-dap-python" },
    },
    {
        "glacambre/firenvim",               -- Integrates neovim into the browser
        config = get_plugin_file("firenvim.lua"),
        run = function() vim.fn["firenvim#install"](0) end,
    },
    {
        "hrsh7th/nvim-cmp",                 -- Support for autocompetion
        config = get_plugin_file("cmp.lua"),
        requires = {
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-cmdline" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
            { "saadparwaiz1/cmp_luasnip", after="LuaSnip" },
        },
    },
    {
        "neovim/nvim-lspconfig",            -- default lang server configurations
        config = function()
            require("snvim.lsp")
        end,
        after = "nvim-cmp",     -- To advertise cmp capabilities to lang servers
        requires = {
            { "williamboman/nvim-lsp-installer" },  -- LSP auto-installer
        },
    },

    {
        "nvim-telescope/telescope.nvim",
        config = get_plugin_file("telescope.lua"),
        requires = {
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
            { "BurntSushi/ripgrep" },
        },
    },
}

return plugin_list
