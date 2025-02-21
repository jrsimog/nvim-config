-- keymaps.lua - Configuración de atajos de teclado en Neovim

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Mapeos generales
map('n', '<leader>w', ':w<CR>', opts) -- Guardar archivo
map('n', '<leader>q', ':q<CR>', opts) -- Salir de Neovim
map('n', '<leader>h', ':nohlsearch<CR>', opts) -- Limpiar búsqueda
map('n', '<C-s>', ':w<CR>', opts) -- Guardar con Ctrl + S
map('i', '<C-s>', '<Esc>:w<CR>a', opts) -- Guardar en modo inserción con Ctrl + S
map('n', '<leader>c', ':CommentToggle<CR>', opts) -- Comentar línea actual (preservado de configuración anterior)

-- Navegación entre buffers

map('n', '<Tab>', ':BufferLineCycleNext<CR>', opts) -- Siguiente buffer
map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', opts) -- Buffer anterior
map('n', '<leader>bp', ':BufferLinePick<CR>', opts) -- Seleccionar buffer
map('n', '<leader>bc', ':BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>', opts) -- Cerrar buffers excepto el actual


-- Atajos de Telescope (búsquedas avanzadas)
map('n', '<leader>ff', ':Telescope find_files<CR>', opts) -- Buscar archivos
map('n', '<leader>fg', ':Telescope live_grep<CR>', opts) -- Buscar en contenido
map('n', '<leader>fb', ':Telescope buffers<CR>', opts) -- Buscar buffers abiertos
map('n', '<leader>fh', ':Telescope help_tags<CR>', opts) -- Buscar en ayuda
map('n', '<leader>fm', ':Telescope marks<CR>', opts) -- Buscar marcadores

-- Atajos para LSP
map('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', opts) -- Ir a definición
map('n', 'gr', ':lua vim.lsp.buf.references()<CR>', opts) -- Buscar referencias
map('n', 'K', ':lua vim.lsp.buf.hover()<CR>', opts) -- Mostrar información de símbolo
map('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', opts) -- Renombrar variable
map('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>', opts) -- Sugerencias de código

-- Atajos para Depuración con DAP
map('n', '<leader>dc', ':lua require"dap".continue()<CR>', opts) -- Continuar depuración
map('n', '<leader>db', ':lua require"dap".toggle_breakpoint()<CR>', opts) -- Agregar/Quitar breakpoint
map('n', '<leader>do', ':lua require"dap".step_over()<CR>', opts) -- Paso sobre la línea
map('n', '<leader>di', ':lua require"dap".step_into()<CR>', opts) -- Paso dentro de la función
map('n', '<leader>du', ':lua require"dap".step_out()<CR>', opts) -- Salir de la función actual
map('n', '<leader>dt', ':lua require"dap".terminate()<CR>', opts) -- Terminar sesión de depuración

-- Atajos para Avante.nvim (IA)
map('n', '<leader>ai', ':AvanteChat<CR>', opts) -- Abrir chat de IA
map('v', '<leader>ac', ':AvanteComplete<CR>', opts) -- Completar código con IA
map('n', '<leader>ae', ':AvanteExplain<CR>', opts) -- Explicar código con IA
map('n', '<leader>ar', ':AvanteRefactor<CR>', opts) -- Refactorizar código con IA
map('n', '<leader>af', ':AvanteFix<CR>', opts) -- Arreglar errores con IA

map('n', '<leader>e', ':NvimTreeFindFileToggle<CR>', opts) -- Abrir/cerrar NvimTree

map('n', '<leader>pp', ':Telescope projects<CR>', opts) -- Abrir proyectos recientes

return {}
