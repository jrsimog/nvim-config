-- keymaps.lua - Configuración de atajos de teclado en Neovim

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Funciones para manejo de Git
vim.cmd [[
function! GitDiffWithBranchPrompt()
  let branch_name = input('Enter branch name to compare: ')
  execute 'Gdiffsplit' branch_name
endfunction

function! GitCommitWithMessagePrompt()
  let commit_message = input('Enter commit message: ')
  if commit_message != ''
    execute 'Git commit -m' shellescape(commit_message)
  else
    echo "Commit canceled: No commit message provided."
  endif
endfunction

function! CustomGitAdd()
  let files = systemlist('git ls-files --others --exclude-standard')
  let selection = inputlist(['Select a file to add:'] + files)
  if selection > 0
    let file = files[selection - 1]
    execute 'silent !git add ' . shellescape(file)
    echo 'Added file: ' . file
  else
    echo 'No file selected.'
  endif
endfunction
function! CreateGitBranch()
  let branch_name = input('Enter new branch name: ')
  if branch_name != ''
    execute 'Git checkout -b ' . branch_name
    echo 'Branch created and switched to: ' . branch_name
  else
    echo 'Branch creation canceled: No name provided.'
  endif
endfunction

function! DeleteGitBranch()
  let branch_name = input('Enter branch name to delete: ')
  if branch_name != ''
    if confirm("Are you sure you want to delete the branch: " . branch_name, "&Yes\n&No", 2) == 1
      execute 'Git branch -D ' . branch_name
      echo 'Branch deleted: ' . branch_name
    else
      echo 'Branch deletion canceled.'
    endif
  else
    echo 'Branch deletion canceled: No name provided.'
  endif
endfunction

function! OpenDiffviewWithBranch()
  let branch = input('Enter branch name: ')
  if branch != ""
    execute 'DiffviewOpen ' . branch
  else
    echo "No branch name provided."
  endif
endfunction

]]

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
map('n', '<leader>ff', ':Telescope find_files no_ignore=true<CR>', opts) -- Buscar archivos
map('n', '<leader>fg', ':Telescope live_grep no_ignore=true<CR>', opts) -- Buscar en contenido
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
map('n', '<leader>gs', ':Telescope git_status<CR>', opts) -- Mostrar estado de Git
map('n', '<leader>gc', ':call GitCommitWithMessagePrompt()<CR>', opts) -- Hacer commit
map('n', '<leader>gp', ':Git push<CR>', opts) -- Hacer push
map('n', '<leader>gl', ':Git pull<CR>', opts) -- Hacer pull
map('n', '<leader>gb', ':Telescope git_branches<CR>', opts) -- Ver ramas
map('n', '<leader>gco', ':Git checkout ', opts) -- Cambiar de rama
-- map('n', '<leader>gd', ':call GitDiffWithBranchPrompt()<CR>', opts) -- Mostrar diferencias
map('n', '<leader>ga', ':call CustomGitAdd()<CR>', opts) -- Agregar todos los cambios al staging
map('n', '<leader>gr', ':Git reset<CR>', opts) -- Resetear cambios
map('n', '<leader>gm', ':Git merge ', opts) -- Fusionar ramas
map('n', '<leader>gt', ':Git tag ', opts) -- Crear un tag
map('n', '<leader>gbl', ':Git blame<CR>', opts) -- Mostrar blame de Git
map('n', '<leader>gcb', ':call CreateGitBranch()<CR>', opts)  -- Crear rama
map('n', '<leader>gdb', ':call DeleteGitBranch()<CR>', opts)  -- Eliminar ram


-- Diffview keymaps
map('n', '<leader>dv', ':call OpenDiffviewWithBranch()<CR>', opts)  -- Abrir diffview con input para rama
map('n', '<leader>dq', ':DiffviewClose<CR>', opts) -- Cerrar diffview
map('n', '<leader>dn', ':DiffviewNextFile<CR>', opts) -- Siguiente archivo en diffview
map('n', '<leader>dp', ':DiffviewPrevFile<CR>', opts) -- Archivo anterior en diffview
map('n', '<leader>dj', ':DiffviewNextHunk<CR>', opts) -- Siguiente cambio en diffview
map('n', '<leader>dk', ':DiffviewPrevHunk<CR>', opts) -- Cambio anterior en diffview

-- Atajos para REST.nvim
map('n', '<leader>rr', ':Rest run<CR>', opts) -- Ejecutar la petición HTTP en la línea actual
map('n', '<leader>rp', ':Rest run last<CR>', opts) -- Ejecutar la última petición HTTP
map('n', '<leader>re', ':Rest run<CR>', opts) -- Ejecutar petición actual y mostrar en split

-- Teclas para abrir y cerrar todos los folds
map('n', '<leader>fo', ':foldopen!<CR>', opts)  -- Abrir todos los folds
map('n', '<leader>fc', ':foldclose!<CR>', opts) -- Cerrar todos los folds
-- Configuración de teclas para Emmet
map('n', '<C-Z>', '<Plug>(emmet-expand-abbr)', opts)  -- Expandir abreviatura en modo normal
map('i', '<C-Z>', '<Plug>(emmet-expand-abbr)', opts)  -- Expandir abreviatura en modo insertar


-- Mapeos para Laravel
map('n', '<leader>pl', ':Laravel<CR>', opts)
-- Mapeos para Symfony
map('n', '<leader>ps', ':!symfony server:start<CR>', opts)
map('n', '<leader>pc', ':!symfony console<CR>', opts)

-- Aquí puedes seguir agregando otros mapeos globales o específicos para otros perfiles
return {}
