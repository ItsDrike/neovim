local M = {}

local icons = require("svim.vars.icons").diagnostics

-- Use LSP's highlight capabilities if available for highlighting
M.document_highlight = true

-- Show LSP progress messages
M.show_lsp_progress = false

-- options for vim.diagnostic.config
M.diagnostic_opts = {
  signs = {
    active = true,
    values = {
      { name = "DiagnosticSignError", text = icons.Error },
      { name = "DiagnosticSignWarn", text = icons.Warn },
      { name = "DiagnosticSignHint", text = icons.Hint },
      { name = "DiagnosticSignInfo", text = icons.Information },
    },
  },
  virtual_text = { spacing = 4, prefix = require("svim.vars.icons").ui.Circle },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    format = function(d)
      local code = d.code or (d.user_data and d.user_data.lsp.code)
      if code then
        return string.format("%s [%s]", d.message, code):gsub("1. ", "")
      end
      return d.message
    end,
  },
}

-- Options for floating window shown on hover or signature help
-- (will only be applied as a fallback, if noice isn't installed / is disabled for these)
M.float_opts = {
  focusable = true,
  style = "minimal",
  border = "rounded",
}

-- Options passed to mason-null-ls setup function
M.mason_null_ls_opts = {
  automatic_setup = true,
  ensure_installed = {
    -- "stylua",
    -- "jq",
    -- "flake8",
  }
}

M._common_capabilities = nil

-- Gloabl helper variables for show_lsp_progress function
M._null_ls_token = nil
M._ltex_token = nil

local function show_lsp_progress(_, result, ctx)
  local value = result.value
  if not value.kind then
    return
  end

  local client_id = ctx.client_id
  local name = vim.lsp.get_client_by_id(client_id).name

  if name == "null-ls" then
    -- Prevent repeting messages
    if result.token == M._null_ls_token then
      return
    end
    if value.title == "formatting" then
      M._null_ls_token = result.token
      return
    end
  end

  if name == "ltex" then
    if result.token == M._ltex_token then
      return
    end
    if value.title == "Checking document" then
      M._ltex_token = result.token
      return
    end
  end

  if value.message == nil or value.title == nil then
    return
  end

  vim.notify(value.message, "info", { title = value.title })
end

---Get common capabilities shared for all language servers
---Cache the results if ran more than once
function M.get_common_capabilities()
  if not M._common_capabilities then
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
      return cmp_nvim_lsp.default_capabilities()
    end

    M._common_capabilities = vim.lsp.protocol.make_client_capabilities()
    M._common_capabilities.textDocument.completion.completionItem.snippetSupport = true
    M._common_capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    }
  end

  return M._common_capabilities
end

function M.init()
  -- Use custom icons for diagnostic signs
  for name, icon in pairs(require("svim.vars.icons").diagnostics) do
    name = "DiagnosticSign" .. name
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end

  -- Configure diagnostic options
  vim.diagnostic.config(M.diagnostic_opts)

  -- Configure handlers (hover, signature) float window style
  M.setup_handlers()

  -- Run M.on_attach and M.on_detach any time a language server is attached/detached to/from a buffer
  require("svim.utils.lsp").on_attach(M.on_attach)
  require("svim.utils.lsp").on_detach(M.on_detach)

  -- Setup the language servers installed by mason with our setup function
  local mason_ok, mason = pcall(require, "mason-lspconfig")
  if not mason_ok then
    vim.notify("Unable to setup mason language servers, mason-lspconfig plugin not available!", vim.log.levels.WARN)
  else
    mason.setup_handlers({ M.setup })
  end

  -- Setup null-ls for integrating external linters/formatters via LSP
  --require("svim.plugins.lsp.null-ls").setup(M.get_common_capabilities())
  M.setup_null_ls()

  -- Enable autoformatting (if svim.vars.init.autoformat)
  require("svim.plugins.lsp.format").configure_format_on_save()
end

---Configure style of floating windows for hover and signature help, unless they're already handled by noice
function M.setup_handlers()
  local noice_hover, noice_signature, noice_progress
  ---@cast noice_hover boolean
  ---@cast noice_signature boolean
  if require("svim.utils.plugins").has("noice.nvim") then
    local noice_ok, noice_config = pcall(require, "noice.config")
    if not noice_ok then
      vim.notify("Noice was marked installed, but required failed!", vim.log.levels.ERROR)
      noice_hover = false
      noice_signature = false
      noice_progress = false
    else
      -- Any of the fields can be nil
      noice_hover = noice_config.options.lsp and noice_config.options.lsp.hover and noice_config.options.lsp.hover.enabled or false
      noice_signature = noice_config.options.lsp and noice_config.options.lsp.signature and noice_config.options.lsp.signature.enabled or false
      noice_progress = noice_config.options.lsp and noice_config.options.lsp.progress and noice_config.options.lsp.progress.enabled or false
      end
    end

  if not noice_hover then
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, M.float_opts)
  end
  if not noice_signature then
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, M.float_opts)
  end
  if not noice_progress and M.show_lsp_progress then
    vim.lsp.handlers["$/progress"] = show_lsp_progress
  end
end

---Get configuration options for given language server
---@param server_name string
---@return table
function M.get_config(server_name)
  local defaults = {
    capabilities = M.get_common_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "svim/plugins/lsp/providers/" .. server_name)
  if has_custom_provider then
    defaults = vim.tbl_deep_extend("force", defaults, custom_config)
  end

  return defaults

end

---Function responsible for setting up given language server (with lspconfig)
---@param server string
function M.setup(server)
  local status_ok, lspconfig = pcall(require, "lspconfig")

  if not status_ok then
    vim.notify("Unable to setup " .. server .. " language server, lspconfig plugin not available!", vim.log.levels.ERROR)
    error("Exiting")
  end

  lspconfig[server].setup(M.get_config(server))
end

---Function responsible for setting up given language server (with lspconfig)
function M.setup_null_ls()
  local null_ls_ok, null_ls = pcall(require, "null-ls")
  if not null_ls_ok then
    vim.notify("Unable to setup null ls servers, null-ls plugin not available!")
    return
  end

  local mason_null_ls_ok, mason_null_ls = pcall(require, "mason-null-ls")
  if not mason_null_ls_ok then
    vim.notify("Unable to setup mason null ls servers, mason-null-ls plugin not available!", vim.log.levels.WARN)
    return
  end

  mason_null_ls.setup(M.mason_null_ls_opts)
  null_ls.setup({ sources = {} })  -- { sources = { ...} } can be passed, for extra non-mason null-ls sources

  if M.mason_null_ls_opts.automatic_setup then
    mason_null_ls.setup_handlers()
  end
end

---Function ran every time a language server is added (attached) to a buffer
function M.on_attach(client, bufnr)
  require("svim.plugins.lsp.keymaps").on_attach(client, bufnr)
  M.setup_codelens_refresh(client, bufnr)
  M.add_lsp_buffer_options(client, bufnr)
  M.add_document_symbols(client, bufnr)

  if M.document_highlight then
    M.setup_document_highlight(client, bufnr)
  end

  -- Neovim automatically overrides formatexpr when a language server has
  -- documentFormattingProvider capability, changing it to calling LSP's format functionality.
  --
  -- However this causes an issue with null-ls, which declares all capabilities, so that it can
  -- support any of it's underlying sources, which however might not actually have formatting
  -- ability. (Such as with prettier attaching to markdown, but not having range formatting).
  --
  -- This then causes using gq to wrap text to not do anything, since it just calls LSP's format,
  -- which it can't do.
  --
  -- This should only affect null-ls though, Since normal LSP servers don't behave like this, and
  -- they only declare those abilities that they actually have.
  --
  -- HACK: This resets formatexpr when using null-ls on a filetype that doesn't have a source
  -- capable of doing formatting, even though null-ls declares that it does.
  --
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
  if client.server_capabilities.documentFormattingProvider then
    if client.name == "null-ls" and not require("null-ls.generators").can_run(
      vim.bo[bufnr].filetype,
      require("null-ls.methods").lsp.FORMATTING
    ) then
      vim.bo[bufnr].formatexpr = nil
    end
  end
end

---Function ran just before a language server is detached from a buffer
function M.on_detach(_, _)
  if M.document_highlight then
    pcall(function()
      vim.api.nvim_clear_autocmds({ group = "lsp_document_highlight" })
    end)
  end
end

function M.add_lsp_buffer_options(_, bufnr)
  -- enable completion triggered by <C-x><C-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  -- use gq for formatting
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})")
end

function M.setup_document_highlight(client, bufnr)
  -- Skip document highlighting if illuminate is already active
  if require("svim.utils.plugins").has("vim-illuminate") then
    return
  end

  local status_ok, highlight_supported = pcall(function()
    return client.supports_method "textDocument/documentHighlight"
  end)
  if not status_ok or not highlight_supported then
    return
  end
  local group = "lsp_document_highlight"
  local hl_events = { "CursorHold", "CursorHoldI" }

  local ok, hl_autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = group,
    buffer = bufnr,
    event = hl_events,
  })

  if ok and #hl_autocmds > 0 then
    return
  end

  vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_create_autocmd(hl_events, {
    group = group,
    buffer = bufnr,
    callback = vim.lsp.buf.document_highlight,
  })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end

function M.add_document_symbols(client, bufnr)
  vim.g.navic_silence = false -- can be set to true to suppress error

  local symbols_supported = client.supports_method "textDocument/documentSymbol"
  if not symbols_supported then
    return
  end

  local status_ok, navic = pcall(require, "nvim-navic")
  if status_ok then
    navic.attach(client, bufnr)
  end
end

function M.setup_codelens_refresh(client, bufnr)
  local status_ok, codelens_supported = pcall(function()
    return client.supports_method "textDocument/codeLens"
  end)
  if not status_ok or not codelens_supported then
    return
  end
  local group = "lsp_code_lens_refresh"
  local cl_events = { "BufEnter", "InsertLeave" }
  local ok, cl_autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = group,
    buffer = bufnr,
    event = cl_events,
  })

  if ok and #cl_autocmds > 0 then
    return
  end
  vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_create_autocmd(cl_events, {
    group = group,
    buffer = bufnr,
    callback = vim.lsp.codelens.refresh,
  })
end

return M
