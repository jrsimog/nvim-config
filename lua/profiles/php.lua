-- php.lua - Perfil para PHP, Symfony y Laravel

-- Configuración específica para PHP
local lspconfig = require('lspconfig')

-- Configurar Intelephense para PHP
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      completion = { fullyQualifyGlobalConstantsAndFunctions = true },
    }
  }
})

-- Configuración de Laravel
vim.g.laravel_cache = 1

-- Atajos de teclado específicos para PHP
vim.api.nvim_set_keymap('n', '<leader>pa', ':PhpactorContextMenu<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>pl', ':Laravel<CR>', { noremap = true, silent = true })

