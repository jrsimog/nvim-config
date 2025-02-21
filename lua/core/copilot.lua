-- copilot.lua - Configuración de GitHub Copilot en Neovim

require('copilot').setup({
  panel = { enabled = false }, -- Deshabilita el panel flotante de Copilot
  suggestion = { enabled = false }, -- Deshabilita las sugerencias inline nativas
  filetypes = {
    yaml = true,
    markdown = true,
    help = false,
    gitcommit = true,
    gitrebase = false,
    hgcommit = false,
    ['.'] = false, -- Deshabilitado para otros archivos por defecto
  },
})

-- Integración con nvim-cmp
require('copilot_cmp').setup()

