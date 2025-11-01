-- theme.lua - Configuración centralizada de apariencia en Neovim

-- Habilitar colores en terminal
vim.o.termguicolors = true

-- ========================================
-- TEMA PRINCIPAL
-- ========================================
-- Cambiar aquí para modificar el tema en toda la aplicación
local status_ok, _ = pcall(vim.cmd, "colorscheme monokai")
if not status_ok then
	-- Fallback to default if monokai is not available
	vim.cmd("colorscheme default")
end

-- ========================================
-- CONFIGURACIÓN PERSONALIZADA DE COLORES
-- ========================================

-- Colores personalizados para diffs (Git)
vim.cmd [[
  highlight DiffAdd    guibg=#294436 gui=none
  highlight DiffDelete guibg=#402b2b gui=none
  highlight DiffChange guibg=#1c4881 gui=none
  highlight DiffText   guibg=#265478 gui=none
]]

-- Mejorar visibilidad de diagnósticos
vim.cmd [[
  highlight DiagnosticError guifg=#ff6b6b gui=bold
  highlight DiagnosticWarn  guifg=#feca57 gui=bold
  highlight DiagnosticInfo  guifg=#48cae4 gui=bold
  highlight DiagnosticHint  guifg=#06d6a0 gui=bold
]]

-- ========================================
-- CONFIGURACIÓN DE INTERFAZ
-- ========================================

-- Línea de estado
vim.o.laststatus = 2  -- Siempre mostrar statusline
vim.o.showmode = false -- No mostrar modo (lo maneja lualine)

-- Números de línea
vim.wo.number = true         -- Números absolutos
vim.wo.relativenumber = true -- Números relativos

-- Resaltado visual
vim.wo.cursorline = true     -- Resaltar línea actual
vim.o.colorcolumn = "80,120" -- Guías de columna

-- Transparencia y bordes (opcional)
-- vim.cmd([[highlight Normal guibg=NONE ctermbg=NONE]])
-- vim.cmd([[highlight NormalFloat guibg=NONE]])

-- Tema monokai aplicado exitosamente
