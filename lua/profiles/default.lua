-- default.lua - Perfil por defecto (Elixir & Phoenix, Postgres, MySQL)

-- Configuración específica para Elixir & Phoenix
local lspconfig = require('lspconfig')

-- Configurar ElixirLS (Elixir Language Server)
lspconfig.elixirls.setup({
  cmd = { "elixir-ls" },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
      suggestSpecs = true,
      signatureAfterComplete = true,
      mixEnv = "dev"
    }
  }
})

-- Configurar bases de datos (Postgres y MySQL)
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_auto_execute_table_helpers = 1

-- Atajos de teclado específicos para bases de datos
vim.api.nvim_set_keymap('n', '<leader>db', ':DBUIToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dp', ':DBUIFindBuffer<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dr', ':DBUIRenameBuffer<CR>', { noremap = true, silent = true })

-- Formato automático con Mix
vim.cmd [[autocmd BufWritePre *.ex,*.exs lua vim.lsp.buf.format()]]

-- Configuración adicional para tests en Elixir
vim.cmd [[autocmd BufWritePost *_test.exs silent! !mix test %]]

