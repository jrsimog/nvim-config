-- php.lua - Perfil para PHP, Symfony y Laravel
print("🐘 Cargando perfil PHP con Symfony y Laravel")

local lspconfig = require("lspconfig")

lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      completion = { fullyQualifyGlobalConstantsAndFunctions = true },
    }
  }
})

vim.g.laravel_cache = 1

vim.api.nvim_set_keymap('n', '<leader>pl', ':Laravel<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>ps', ':!symfony server:start<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>pc', ':!symfony console<CR>', { noremap = true, silent = true }) 

-- Formateo automático con php-cs-fixer antes de guardar
vim.cmd [[autocmd BufWritePre *.php lua vim.lsp.buf.format()]]

