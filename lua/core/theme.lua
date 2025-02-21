-- theme.lua - Configuración de apariencia en Neovim

vim.o.termguicolors = true -- Habilitar colores en terminal
vim.cmd [[colorscheme monokai ]] -- Aplicar el esquema de colores

-- Configuración de la apariencia de la línea de estado
vim.o.laststatus = 2
vim.o.showmode = false

-- Configuración de la apariencia de los números de línea
vim.wo.number = true
vim.wo.relativenumber = true

-- Resaltar la línea actual
vim.wo.cursorline = true

