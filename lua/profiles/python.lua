-- python.lua - Perfil para Python

-- Configuración específica para Python
local lspconfig = require('lspconfig')

-- Configurar Pyright para Python
lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true
      }
    }
  }
})

-- Atajos de teclado específicos para Python
vim.api.nvim_set_keymap('n', '<leader>pf', ':Black<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pr', ':!pytest %<CR>', { noremap = true, silent = true })

-- Formato automático con Black
vim.cmd [[autocmd BufWritePre *.py lua vim.lsp.buf.format()]]

