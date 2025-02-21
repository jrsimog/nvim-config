-- Perfil para Elixir (por defecto)
print("⚗️ Cargando perfil Elixir")

vim.g.mapleader = " "
require("core.plugins")  -- Cargar plugins generales
require("core.lsp")  -- Configuración de LSP
require("lspconfig").elixirls.setup({
  cmd = { "/home/jose/.local/share/nvim/mason/bin/elixir-ls" }, -- Verifica la ruta correcta
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false,
    },
  },
})
