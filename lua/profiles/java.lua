-- java.lua - Perfil para Java

-- Configuración específica para Java
local lspconfig = require('lspconfig')

-- Configurar jdtls para Java
lspconfig.jdtls.setup({
  cmd = { "jdtls" },
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" }
    }
  }
})

-- Atajos de teclado específicos para Java
vim.api.nvim_set_keymap('n', '<leader>jc', ':JdtCompile<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>jr', ':JdtUpdateConfig<CR>', { noremap = true, silent = true })

-- Formato automático con Google Java Format
vim.cmd [[autocmd BufWritePre *.java lua vim.lsp.buf.format()]]

