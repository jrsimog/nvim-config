-- Perfil para Elixir (por defecto)
print("⚗️ Cargando perfil Elixir")

vim.g.mapleader = " "
require("core.plugins")
require("core.lsp")

local lspconfig = require("lspconfig")
lspconfig.elixirls.setup({
  cmd = { "/home/jose/.local/share/nvim/mason/bin/elixir-ls" },
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false,
    },
  },
})

-- Formato automático al guardar con mix format
vim.cmd [[autocmd BufWritePre *.ex,*.exs lua vim.lsp.buf.format()]]
