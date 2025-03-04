-- theme.lua - Configuración de apariencia en Neovim

vim.o.termguicolors = true -- Habilitar colores en terminal
vim.cmd("colorscheme monokai") -- Aplicar el esquema de colores

-- Configuración personalizada de colores para diffs
vim.cmd [[
  highlight DiffAdd    guibg=#294436 gui=none
  highlight DiffDelete guibg=#402b2b gui=none
  highlight DiffChange guibg=#1c4881 gui=none
  highlight DiffText   guibg=#265478 gui=none
]]

-- Configuración de la apariencia de la línea de estado
vim.o.laststatus = 2
vim.o.showmode = false

-- Configuración de la apariencia de los números de línea
vim.wo.number = true
vim.wo.relativenumber = true

-- Resaltar la línea actual
vim.wo.cursorline = true
