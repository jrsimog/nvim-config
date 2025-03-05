print("🐘 Cargando perfil PHP con Symfony, Laravel, Twig y HTML")

local lspconfig = require("lspconfig")

-- Configuración para Intelephense
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      completion = { fullyQualifyGlobalConstantsAndFunctions = true },
    }
  }
})

-- Configuración para Twig y HTML
vim.api.nvim_create_autocmd("BufRead,BufNewFile", {
    pattern = {"*.twig", "*.html"},
    command = "setlocal filetype=html"
})

vim.g.laravel_cache = 1

-- Formateo automático con php-cs-fixer antes de guardar
vim.cmd [[autocmd BufWritePre *.php lua vim.lsp.buf.format()]]

-- Configuración adicional para mejorar el soporte de HTML/Twig
-- Aquí podrías agregar plugins o ajustes específicos para trabajar mejor con estos formatos
