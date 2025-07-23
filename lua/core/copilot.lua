-- lua/core/copilot.lua - Configuración para copilot.vim

-- 1. Deshabilitar Copilot por defecto para control manual.
vim.g.copilot_enabled = 0

-- 2. Prevenir que Copilot mapee la tecla Tab.
--    Esto es crucial para evitar conflictos con plugins de autocompletado como nvim-cmp.
vim.g.copilot_no_tab_map = true

-- 3. Asignar una tecla explícita para aceptar sugerencias usando la variable del plugin.
--    Usamos <C-l> (Ctrl+L) para no interferir con otras teclas comunes.
vim.g.copilot_suggestion_map_accept = '<C-l>'
