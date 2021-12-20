-- Neovim has built in support for the language server protocol (LSP). For
-- which reason I decided to utilize it directly instead of relying on plugins
-- such as COC, which reimplement it completely just to support default vim
-- too, since I don't need pure vim support, utilizing this built in support
-- makes a lot more sense and will be faster.
--
-- By default, setting up LSP doesn't technically require any plugins, however
-- I still do use the recommended neovim/nvim-lspconfig plugin, along with
-- williamboman/nvim-lsp-installer, because it makes things a lot easier to get
-- working. The lspconfig holds the default configurations for the individual
-- language servers, avoiding the need of tediously configuring them manually,
-- and the lspinstaller gives us a way to automatically install selected
-- language servers locally for nvim only, which means we won't need to look at
-- the install instructions for each language server and install it user or
-- system wide.
--
-- This means that some functions/files in this configurations are plugin
-- dependant, which means that this file should only be ran after LSP related
-- plugins finished loading. However most of the code in here is actually
-- plugin independant making it somewhat easy to switch those plugins if
-- needed, or even remove them in favor of manual implementations in case it
-- ever comse up. If a file/function is plugin-dependant, it will be mentioned
-- on the top of that file/function

require("snvim.lsp.lsp_installer")
require("snvim.lsp.keymaps")
require("snvim.lsp.autoformat")
