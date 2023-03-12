local opts = {}

local schemastore_ok, schemastore = pcall(require, "schemastore")
if schemastore_ok then
  opts.settings = { json = { schemas = schemastore.json.schemas() } }
end

opts.setup = {
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
      end,
    },
  },
}

return opts
