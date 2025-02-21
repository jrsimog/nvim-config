-- php.lua - Perfil para PHP, Symfony y Laravel
print("🐘 Cargando perfil PHP con Symfony y Laravel")

local lspconfig = require('lspconfig')

-- Configurar LSP para PHP con Intelephense
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      completion = { fullyQualifyGlobalConstantsAndFunctions = true },
    }
  }
})

-- Configuración para Laravel
vim.g.laravel_cache = 1

-- Atajos de teclado para PHP, Laravel y Symfony
vim.api.nvim_set_keymap('n', '<leader>pl', ':Laravel<CR>', { noremap = true, silent = true }) -- Laravel CLI
vim.api.nvim_set_keymap('n', '<leader>ps', ':!symfony server:start<CR>', { noremap = true, silent = true }) -- Symfony Server
vim.api.nvim_set_keymap('n', '<leader>pc', ':!symfony console<CR>', { noremap = true, silent = true }) -- Symfony Console
