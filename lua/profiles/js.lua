-- js.lua - Perfil para JavaScript, React y Node.js

-- Configuración específica para JavaScript y TypeScript
local lspconfig = require('lspconfig')

-- Configurar tsserver para JavaScript y TypeScript
lspconfig.tsserver.setup({
  settings = {
    completions = {
      completeFunctionCalls = true
    }
  }
})

-- Configurar eslint para validaciones
lspconfig.eslint.setup({
  settings = {
    format = true,
    lintTask = { enable = true }
  }
})

-- Atajos de teclado específicos para JavaScript y React
vim.api.nvim_set_keymap('n', '<leader>jf', ':EslintFixAll<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>jr', ':TSC<CR>', { noremap = true, silent = true })

-- Formato automático con Prettier
vim.cmd [[autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx lua vim.lsp.buf.format()]]

