-- keymaps.lua - Configuración de atajos de teclado en Neovim

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Mapeos generales
map('n', '<leader>w', ':w<CR>', opts) -- Guardar archivo
map('n', '<leader>q', ':q<CR>', opts) -- Salir de Neovim
map('n', '<leader>h', ':nohlsearch<CR>', opts) -- Limpiar búsqueda
map('n', '<C-s>', ':w<CR>', opts) -- Guardar con Ctrl + S
map('i', '<C-s>', '<Esc>:w<CR>a', opts) -- Guardar en modo inserción con Ctrl + S
map('n', '<leader>l', ':noh<CR>', opts) -- limpiar la seleccion en panatalla

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
map('n', '<leader>ai', ':AvanteChat<CR>', opts)      -- Abrir chat de IA
map('v', '<leader>ac', ':AvanteComplete<CR>', opts)  -- Completar código con IA
map('n', '<leader>ae', ':AvanteExplain<CR>', opts)   -- Explicar código con IA
map('n', '<leader>ar', ':AvanteRefactor<CR>', opts)  -- Refactorizar código con IA
map('n', '<leader>af', ':AvanteFix<CR>', opts)       -- Arreglar errores con IA
map('n', '<leader>ap', ':AvanteCursorPlanningMode<CR>', opts) -- Modo de planeación (cursor-planning-mode)

-- Atajos para Navegación de directorios
map('n', '<leader>e', ':NvimTreeFindFileToggle<CR>', opts) -- Abrir/cerrar NvimTree

map('n', '<leader>pp', ':Telescope projects<CR>', opts) -- Abrir proyectos recientes

-- Atajos para Git
map('n', '<leader>gs', ':Git status<CR>', opts) -- Mostrar estado de Git
map('n', '<leader>gc', ':Git commit<CR>', opts) -- Hacer commit
map('n', '<leader>gp', ':Git push<CR>', opts) -- Hacer push
map('n', '<leader>gl', ':Git pull<CR>', opts) -- Hacer pull
map('n', '<leader>gb', ':Git branch<CR>', opts) -- Ver ramas
map('n', '<leader>gco', ':Git checkout ', opts) -- Cambiar de rama
map('n', '<leader>gd', ':Git diff<CR>', opts) -- Mostrar diferencias
map('n', '<leader>ga', ':Git add .<CR>', opts) -- Agregar todos los cambios al staging
map('n', '<leader>gr', ':Git reset<CR>', opts) -- Resetear cambios
map('n', '<leader>gm', ':Git merge ', opts) -- Fusionar ramas
map('n', '<leader>gt', ':Git tag ', opts) -- Crear un tag
map('n', '<leader>gbl', ':Git blame<CR>', opts) -- Mostrar blame de Git

-- Atajos para REST.nvim
map('n', '<leader>rr', ':Rest run<CR>', opts) -- Ejecutar la petición HTTP en la línea actual
map('n', '<leader>rp', ':Rest run last<CR>', opts) -- Ejecutar la última petición HTTP
map('n', '<leader>re', ':Rest run<CR>', opts) -- Ejecutar petición actual y mostrar en split

return {}
