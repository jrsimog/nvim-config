-- core/keymaps.lua - Configuración de atajos de teclado en Neovim

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
map('n', '<leader>w', ':w<CR>', opts)          -- Guardar archivo
map('n', '<leader>q', ':q<CR>', opts)          -- Salir de Neovim
map('n', '<leader>h', ':nohlsearch<CR>', opts) -- Limpiar búsqueda
map('n', '<C-s>', ':w<CR>', opts)              -- Guardar con Ctrl + S
map('i', '<C-s>', '<Esc>:w<CR>a', opts)        -- Guardar en modo inserción con Ctrl + S
map('n', '<leader>l', ':noh<CR>', opts)        -- limpiar la seleccion en panatalla

-- Navegación entre buffers

map('n', '<Tab>', ':BufferLineCycleNext<CR>', opts)                               -- Siguiente buffer
map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', opts)                             -- Buffer anterior
map('n', '<leader>bp', ':BufferLinePick<CR>', opts)                               -- Seleccionar buffer
map('n', '<leader>bc', ':BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>', opts) -- Cerrar buffers excepto el actual


-- Atajos de Telescope (búsquedas avanzadas)
map('n', '<leader>ff', ':Telescope find_files no_ignore=true<CR>', opts) -- Buscar archivos
map('n', '<leader>fg', ':Telescope live_grep no_ignore=true<CR>', opts)  -- Buscar en contenido
map('n', '<leader>fb', ':Telescope buffers<CR>', opts)                   -- Buscar buffers abiertos
map('n', '<leader>fh', ':Telescope help_tags<CR>', opts)                 -- Buscar en ayuda
map('n', '<leader>fm', ':Telescope marks<CR>', opts)                     -- Buscar marcadores

-- Atajos para LSP
map('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', opts)          -- Ir a definición
map('n', 'gr', ':lua vim.lsp.buf.references()<CR>', opts)          -- Buscar referencias
map('n', 'K', ':lua vim.lsp.buf.hover()<CR>', opts)                -- Mostrar información de símbolo
map('n', '<leader>rn', ':lua vim.lsp.buf.rename()<CR>', opts)      -- Renombrar variable
map('n', '<leader>ca', ':lua vim.lsp.buf.code_action()<CR>', opts) -- Sugerencias de código

-- Atajos para Depuración con DAP
map('n', '<leader>dc', ':lua require"dap".continue()<CR>', opts)          -- Continuar depuración
map('n', '<leader>db', ':lua require"dap".toggle_breakpoint()<CR>', opts) -- Agregar/Quitar breakpoint
map('n', '<leader>do', ':lua require"dap".step_over()<CR>', opts)         -- Paso sobre la línea
map('n', '<leader>di', ':lua require"dap".step_into()<CR>', opts)         -- Paso dentro de la función
map('n', '<leader>du', ':lua require"dap".step_out()<CR>', opts)          -- Salir de la función actual
map('n', '<leader>dt', ':lua require"dap".terminate()<CR>', opts)         -- Terminar sesión de depuración

-- Atajos para Avante.nvim (IA)
map('n', '<leader>ai', ':AvanteChat<CR>', opts)               -- Abrir chat de IA
map('v', '<leader>ac', ':AvanteComplete<CR>', opts)           -- Completar código con IA
map('n', '<leader>ae', ':AvanteExplain<CR>', opts)            -- Explicar código con IA
map('n', '<leader>ar', ':AvanteRefactor<CR>', opts)           -- Refactorizar código con IA
map('n', '<leader>af', ':AvanteFix<CR>', opts)                -- Arreglar errores con IA
map('n', '<leader>ap', ':AvanteCursorPlanningMode<CR>', opts) -- Modo de planeación (cursor-planning-mode)

-- Atajos para Navegación de directorios
map('n', '<leader>e', ':NvimTreeFindFileToggle<CR>', opts) -- Abrir/cerrar NvimTree

map('n', '<leader>pp', ':Telescope projects<CR>', opts)    -- Abrir proyectos recientes

-- Atajos para Git
map('n', '<leader>gs', ':Telescope git_status<CR>', opts)              -- Mostrar estado de Git
map('n', '<leader>gc', ':call GitCommitWithMessagePrompt()<CR>', opts) -- Hacer commit
map('n', '<leader>gp', ':Git push<CR>', opts)                          -- Hacer push
map('n', '<leader>gl', ':Git pull<CR>', opts)                          -- Hacer pull
map('n', '<leader>gb', ':Telescope git_branches<CR>', opts)            -- Ver ramas
map('n', '<leader>gco', ':Git checkout ', opts)                        -- Cambiar de rama
-- map('n', '<leader>gd', ':call GitDiffWithBranchPrompt()<CR>', opts) -- Mostrar diferencias
map('n', '<leader>ga', ':call CustomGitAdd()<CR>', opts)               -- Agregar todos los cambios al staging
map('n', '<leader>gr', ':Git reset<CR>', opts)                         -- Resetear cambios
map('n', '<leader>gm', ':Git merge ', opts)                            -- Fusionar ramas
map('n', '<leader>gt', ':Git tag ', opts)                              -- Crear un tag
map('n', '<leader>gbl', ':Git blame<CR>', opts)                        -- Mostrar blame de Git
map('n', '<leader>gcb', ':call CreateGitBranch()<CR>', opts)           -- Crear rama
map('n', '<leader>gdb', ':call DeleteGitBranch()<CR>', opts)           -- Eliminar ram


-- Diffview keymaps
map('n', '<leader>dv', ':call OpenDiffviewWithBranch()<CR>', opts) -- Abrir diffview con input para rama
map('n', '<leader>dq', ':DiffviewClose<CR>', opts)                 -- Cerrar diffview
map('n', '<leader>dn', ':DiffviewNextFile<CR>', opts)              -- Siguiente archivo en diffview
map('n', '<leader>dp', ':DiffviewPrevFile<CR>', opts)              -- Archivo anterior en diffview
map('n', '<leader>dj', ':DiffviewNextHunk<CR>', opts)              -- Siguiente cambio en diffview
map('n', '<leader>dk', ':DiffviewPrevHunk<CR>', opts)              -- Cambio anterior en diffview

-- Atajos para REST.nvim
map('n', '<leader>rr', ':Rest run<CR>', opts)      -- Ejecutar la petición HTTP en la línea actual
map('n', '<leader>rp', ':Rest run last<CR>', opts) -- Ejecutar la última petición HTTP
map('n', '<leader>re', ':Rest run<CR>', opts)      -- Ejecutar petición actual y mostrar en split

-- Teclas para abrir y cerrar todos los folds
map('n', '<leader>fo', ':foldopen!<CR>', opts)       -- Abrir todos los folds
map('n', '<leader>fc', ':foldclose!<CR>', opts)      -- Cerrar todos los folds
-- Configuración de teclas para Emmet
map('n', '<C-Z>', '<Plug>(emmet-expand-abbr)', opts) -- Expandir abreviatura en modo normal
map('i', '<C-Z>', '<Plug>(emmet-expand-abbr)', opts) -- Expandir abreviatura en modo insertar


-- Mapeos para Laravel
map('n', '<leader>pl', ':Laravel<CR>', opts)
-- Mapeos para Symfony
map('n', '<leader>ps', ':!symfony server:start<CR>', opts)
map('n', '<leader>pc', ':!symfony console<CR>', opts)

-- Formateo y linting para frontend (usando prefijo 'fe' para evitar conflictos)
-- map('n', '<leader>fep', ':Prettier<CR>', opts) -- Formatear con Prettier
-- Atajos para Formateo con conform.nvim
map('n', '<leader>f', '<cmd>Format<CR>', { noremap = true, silent = true, desc = "Format code" })
map('v', '<leader>f', '<cmd>Format<CR>', { noremap = true, silent = true, desc = "Format selection" })


map('n', '<leader>fee', ':EslintFixAll<CR>', opts)              -- Arreglar errores de ESLint
map('n', '<leader>fei', ':TypescriptOrganizeImports<CR>', opts) -- Organizar importaciones

-- Navegación en proyectos React (usando 'fe' como prefijo)
map('n', '<leader>fet',
    ':lua require("telescope.builtin").find_files({prompt_title = "Tests", cwd = "tests", path_display = { "smart" }})<CR>',
    opts)
map('n', '<leader>fec',
    ':lua require("telescope.builtin").find_files({prompt_title = "Components", cwd = "src/components", path_display = { "smart" }})<CR>',
    opts)
map('n', '<leader>fep',
    ':lua require("telescope.builtin").find_files({prompt_title = "Pages", cwd = "src/pages", path_display = { "smart" }})<CR>',
    opts)
map('n', '<leader>fes',
    ':lua require("telescope.builtin").find_files({prompt_title = "Styles", cwd = "src/styles", path_display = { "smart" }})<CR>',
    opts)

-- TypeScript/React específicos (usando prefijo 'ts')
map('n', '<leader>tsi', ':TSLspImportAll<CR>', opts)  -- Importar todas las referencias
map('n', '<leader>tso', ':TSLspOrganize<CR>', opts)   -- Organizar importaciones
map('n', '<leader>tsr', ':TSLspRenameFile<CR>', opts) -- Renombrar archivo y ajustar importaciones
map('n', '<leader>tsf', ':TSLspFixCurrent<CR>', opts) -- Arreglar problemas en el archivo actual

-- Servidor de desarrollo para HTML/CSS (usando prefijo 'hs' - HTML Server)
map('n', '<leader>hss', ':LiveServerStart<CR>', opts) -- Iniciar Live Server
map('n', '<leader>hsx', ':LiveServerStop<CR>', opts)  -- Detener Live Server

-- Testing para Frontend (usando prefijo 'ft' - Frontend Test)
map('n', '<leader>ftf', ':TestFile<CR>', opts)    -- Ejecutar tests del archivo actual
map('n', '<leader>ftn', ':TestNearest<CR>', opts) -- Ejecutar test más cercano
map('n', '<leader>ftl', ':TestLast<CR>', opts)    -- Ejecutar último test
map('n', '<leader>ftv', ':TestVisit<CR>', opts)   -- Ir al archivo de test

-- Emmet (manteniendo tu configuración actual pero añadiendo opciones)
-- Ya tienes <C-Z> configurado en tu keymaps principal
map('n', '<C-y>e', '<plug>(emmet-expand-abbr)', { silent = true }) -- Alternativa para expandir abreviatura en modo normal
map('i', '<C-y>e', '<plug>(emmet-expand-abbr)', { silent = true }) -- Alternativa para expandir abreviatura en modo inserción

-- NPM scripts (usando prefijo 'np')
map('n', '<leader>nps', ':lua require("package-info").show()<CR>', opts) -- Mostrar info del package.json
map('n', '<leader>npd', ':term npm run dev<CR>', opts)                   -- Ejecutar script de desarrollo
map('n', '<leader>npb', ':term npm run build<CR>', opts)                 -- Construir proyecto
map('n', '<leader>npt', ':term npm test<CR>', opts)                      -- Ejecutar tests
map('n', '<leader>npi', ':term npm install<CR>', opts)                   -- Instalar dependencias

-- Búsquedas específicas Frontend (usando prefijos claros para evitar conflictos)
map('n', '<leader>fef',
    ':lua require("telescope.builtin").find_files({prompt_title="Frontend Files", file_ignore_patterns={}, hidden=true})<CR>',
    opts)
map('n', '<leader>feg',
    ':lua require("telescope.builtin").live_grep({prompt_title="Frontend Grep", additional_args=function() return {"--no-ignore"} end})<CR>',
    opts)

-- Snippets de React (usando prefijo 'rs' - React Snippet)
map('n', '<leader>rsf', 'irfc<Tab>', { noremap = false }) -- Componente funcional de React
map('n', '<leader>rss', 'irus<Tab>', { noremap = false }) -- useState hook
map('n', '<leader>rse', 'irue<Tab>', { noremap = false }) -- useEffect hook
map('n', '<leader>rsc', 'iruc<Tab>', { noremap = false }) -- useContext hook

-- Comandos para crear componentes React
vim.cmd [[
  command! -nargs=1 ReactComponent lua ReactCreateComponent(<f-args>)
  command! -nargs=1 ReactPage lua ReactCreatePage(<f-args>)
]]

vim.api.nvim_exec([[
  function! ReactCreateComponent(name)
    let l:dir = "src/components/" . a:name
    call mkdir(l:dir, "p")

    " Crear archivo de componente
    let l:component_file = l:dir . "/" . a:name . ".jsx"
    call writefile([
      \ "import React from 'react';",
      \ "import './" . a:name . ".css';",
      \ "",
      \ "const " . a:name . " = () => {",
      \ "  return (",
      \ "    <div className=\"" . tolower(a:name) . "\">",
      \ "      <h2>" . a:name . " Component</h2>",
      \ "    </div>",
      \ "  );",
      \ "};",
      \ "",
      \ "export default " . a:name . ";"
    \], l:component_file)

    " Crear archivo CSS
    let l:css_file = l:dir . "/" . a:name . ".css"
    call writefile([
      \ "." . tolower(a:name) . " {",
      \ "  padding: 20px;",
      \ "  margin: 10px;",
      \ "}"
    \], l:css_file)

    " Crear archivo de índice
    let l:index_file = l:dir . "/index.js"
    call writefile([
      \ "export { default } from './" . a:name . "';"
    \], l:index_file)

    echo "Created React component: " . a:name
    execute "edit " . l:component_file
  endfunction

  function! ReactCreatePage(name)
    let l:dir = "src/pages/" . a:name
    call mkdir(l:dir, "p")

    " Crear archivo de página
    let l:page_file = l:dir . "/" . a:name . ".jsx"
    call writefile([
      \ "import React from 'react';",
      \ "import './" . a:name . ".css';",
      \ "",
      \ "const " . a:name . "Page = () => {",
      \ "  return (",
      \ "    <div className=\"" . tolower(a:name) . "-page\">",
      \ "      <h1>" . a:name . " Page</h1>",
      \ "    </div>",
      \ "  );",
      \ "};",
      \ "",
      \ "export default " . a:name . "Page;"
    \], l:page_file)

    " Crear archivo CSS
    let l:css_file = l:dir . "/" . a:name . ".css"
    call writefile([
      \ "." . tolower(a:name) . "-page {",
      \ "  padding: 20px;",
      \ "  margin: 10px;",
      \ "}"
    \], l:css_file)

    " Crear archivo de índice
    let l:index_file = l:dir . "/index.js"
    call writefile([
      \ "export { default } from './" . a:name . "';"
    \], l:index_file)

    echo "Created React page: " . a:name
    execute "edit " . l:page_file
  endfunction
]], false)

-- Atajos para los comandos de creación de componentes y páginas React
map('n', '<leader>rcc', ':ReactComponent ', { noremap = true })
map('n', '<leader>rcp', ':ReactPage ', { noremap = true })

-- -- En core/keymaps.lua
-- map('n', '<C-t>', ':ToggleTerm direction=float<CR>', opts)
-- map('t', '<C-t>', '<C-\\><C-n>:ToggleTerm direction=float<CR>', opts) -- Para cerrar desde modo terminal

-- Retornar un objeto vacío para compatibilidad con require()
return {}
