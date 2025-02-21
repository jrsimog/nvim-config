-- lua/plugins/ufo.lua

-- Configuración básica de Neovim para plegado
vim.o.foldcolumn = '1' -- '0' también es aceptable
vim.o.foldlevel = 99 -- Usando el proveedor ufo se necesita un valor grande, siéntete libre de disminuirlo
vim.o.foldlevelstart = 99
vim.o.foldenable = false

-- Remapear teclas `zR` y `zM` para el proveedor ufo
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

-- Configurar ufo
require('ufo').setup()
