local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- ========================================
-- TUS KEYMAPS EXISTENTES (PRESERVADOS)
-- ========================================

-- Funciones para manejo de Git
vim.cmd([[
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
]])

-- Mapeos generales
map("n", "<leader>w", ":w<CR>", opts) -- Guardar archivo
map("n", "<leader>q", ":q<CR>", opts) -- Salir de Neovim
map("n", "<leader>h", ":nohlsearch<CR>", opts) -- Limpiar búsqueda
map("n", "<C-s>", ":w<CR>", opts) -- Guardar con Ctrl + S
map("i", "<C-s>", "<Esc>:w<CR>a", opts) -- Guardar en modo inserción con Ctrl + S
map("n", "<leader>l", ":noh<CR>", opts) -- limpiar la seleccion en panatalla

-- Navegación entre buffers
map("n", "<Tab>", ":BufferLineCycleNext<CR>", opts) -- Siguiente buffer
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", opts) -- Buffer anterior
map("n", "<leader>bp", ":BufferLinePick<CR>", opts) -- Seleccionar buffer
map("n", "<leader>bc", ":BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>", opts) -- Cerrar buffers excepto el actual

-- Atajos de Telescope (búsquedas avanzadas)
map("n", "<leader>ff", ":Telescope find_files no_ignore=true<CR>", opts) -- Buscar archivos
map("n", "<leader>fg", ":Telescope live_grep no_ignore=true<CR>", opts) -- Buscar en contenido
map("n", "<leader>fr", ":Telescope oldfiles<CR>", opts) -- Buscar buffers abriertos recientemente
map("n", "<leader>fb", ":Telescope buffers<CR>", opts) -- Buscar buffers abiertos
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts) -- Buscar en ayuda
map("n", "<leader>fm", ":Telescope marks<CR>", opts) -- Buscar marcadores

map("n", "<leader>fv", ":Telescope find_files<CR>", opts) -- Buscar archivo normal
map("n", "<leader>fs", ":Telescope find_files<CR><C-x>", opts) -- Buscar y abrir en split horizontal
map("n", "<leader>fv", ":Telescope find_files<CR><C-v>", opts) -- Buscar y abrir en split vertical
map("n", "<leader>ft", ":Telescope find_files<CR><C-t>", opts) -- Buscar y abrir en una nueva pestaña

-- Atajos para LSP
map("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts) -- Ir a definición
map("n", "gr", ":lua vim.lsp.buf.references()<CR>", opts) -- Buscar referencias
map("n", "K", ":lua vim.lsp.buf.hover()<CR>", opts) -- Mostrar información de símbolo
map("n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", opts) -- Renombrar variable
map("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", opts) -- Sugerencias de código

-- Atajos para Depuración con DAP
map("n", "<leader>dc", ':lua require"dap".continue()<CR>', opts) -- Continuar depuración
map("n", "<leader>db", ':lua require"dap".toggle_breakpoint()<CR>', opts) -- Agregar/Quitar breakpoint
map("n", "<leader>do", ':lua require"dap".step_over()<CR>', opts) -- Paso sobre la línea
map("n", "<leader>di", ':lua require"dap".step_into()<CR>', opts) -- Paso dentro de la función
map("n", "<leader>du", ':lua require"dap".step_out()<CR>', opts) -- Salir de la función actual
map("n", "<leader>dt", ':lua require"dap".terminate()<CR>', opts) -- Terminar sesión de depuración

-- ========================================
-- 🧪 ATAJOS MEJORADOS PARA AVANTE.NVIM (ELIXIR/PHOENIX)
-- ========================================

-- Atajos básicos de Avante
map("n", "<leader>aa", ":AvanteAsk ", opts) -- Preguntar a la IA (con prompt)
map("v", "<leader>aa", ":AvanteAsk ", opts) -- Preguntar sobre código seleccionado
map("n", "<leader>ac", ":AvanteChat<CR>", opts) -- Abrir chat de IA
map("n", "<leader>at", ":AvanteToggle<CR>", opts) -- Toggle ventana de Avante

-- Atajos específicos para Elixir con Avante
map(
	"n",
	"<leader>aer",
	":AvanteAsk Refactoriza este código Elixir siguiendo principios de código limpio, usa pattern matching y pipe operators<CR>",
	opts
)
map(
	"v",
	"<leader>aer",
	":AvanteAsk Refactoriza este código Elixir siguiendo principios de código limpio, usa pattern matching y pipe operators<CR>",
	opts
)

map(
	"n",
	"<leader>aet",
	":AvanteAsk Genera tests ExUnit exhaustivos para este módulo, incluye casos edge y doctest<CR>",
	opts
)
map("v", "<leader>aet", ":AvanteAsk Genera tests ExUnit exhaustivos para esta función<CR>", opts)

map("n", "<leader>aeo", ":AvanteAsk Optimiza este código para el BEAM, considera procesos, ETS y memoria<CR>", opts)
map("n", "<leader>aeg", ":AvanteAsk Implementa esto como un GenServer con supervisión OTP<CR>", opts)
map("n", "<leader>aelv", ":AvanteAsk Convierte este controlador Phoenix a LiveView<CR>", opts)
map(
	"n",
	"<leader>aec",
	":AvanteAsk Genera un contexto Phoenix para este dominio con schemas, changesets y funciones<CR>",
	opts
)

-- Documentación con Avante
map("n", "<leader>aed", ":AvanteAsk Busca en la documentación de Elixir sobre ", opts)
map("n", "<leader>aep", ":AvanteAsk Busca en la documentación de Phoenix sobre ", opts)
map("n", "<leader>aeh", ":AvanteAsk Busca en Hex.pm paquetes para ", opts)

-- Explicaciones y aprendizaje
map("n", "<leader>aee", ":AvanteAsk Explica este código Elixir paso a paso<CR>", opts)
map("v", "<leader>aee", ":AvanteAsk Explica este código Elixir paso a paso<CR>", opts)
map("n", "<leader>aeb", ":AvanteAsk ¿Cuáles son las mejores prácticas para esto en Elixir?<CR>", opts)

-- ========================================
-- 🔧 FUNCIONES ESPECÍFICAS PARA ELIXIR
-- ========================================

vim.cmd([[
" Función para crear módulos Elixir
function! ElixirCreateModule()
  let module_name = input('Enter module name (e.g., MyApp.Users.User): ')
  if module_name != ''
    let file_path = 'lib/' . substitute(tolower(module_name), '\.', '/', 'g') . '.ex'
    let dir_path = fnamemodify(file_path, ':h')
    call mkdir(dir_path, 'p')
    
    let module_parts = split(module_name, '\.')
    let module_content = [
      \ 'defmodule ' . module_name . ' do',
      \ '  @moduledoc """',
      \ '  ' . module_parts[-1] . ' module',
      \ '  """',
      \ '',
      \ 'end'
    \ ]
    
    call writefile(module_content, file_path)
    execute 'edit ' . file_path
    echo 'Created Elixir module: ' . module_name
  endif
endfunction

" Función para crear GenServers
function! ElixirCreateGenServer()
  let module_name = input('Enter GenServer module name: ')
  if module_name != ''
    let file_path = 'lib/' . substitute(tolower(module_name), '\.', '/', 'g') . '.ex'
    let dir_path = fnamemodify(file_path, ':h')
    call mkdir(dir_path, 'p')
    
    let genserver_content = [
      \ 'defmodule ' . module_name . ' do',
      \ '  use GenServer',
      \ '',
      \ '  @moduledoc """',
      \ '  GenServer implementation for ' . module_name,
      \ '  """',
      \ '',
      \ '  # Client API',
      \ '',
      \ '  def start_link(opts \\ []) do',
      \ '    GenServer.start_link(__MODULE__, opts, name: __MODULE__)',
      \ '  end',
      \ '',
      \ '  # Server Callbacks',
      \ '',
      \ '  @impl true',
      \ '  def init(opts) do',
      \ '    {:ok, %{}}',
      \ '  end',
      \ '',
      \ '  @impl true',
      \ '  def handle_call(msg, _from, state) do',
      \ '    {:reply, :ok, state}',
      \ '  end',
      \ '',
      \ '  @impl true', 
      \ '  def handle_cast(msg, state) do',
      \ '    {:noreply, state}',
      \ '  end',
      \ 'end'
    \ ]
    
    call writefile(genserver_content, file_path)
    execute 'edit ' . file_path
    echo 'Created GenServer: ' . module_name
  endif
endfunction

" Función para crear LiveView
function! PhoenixCreateLiveView()
  let module_name = input('Enter LiveView module name (e.g., MyAppWeb.UserLive.Index): ')
  if module_name != ''
    let file_path = 'lib/' . substitute(tolower(module_name), '\.', '/', 'g') . '.ex'
    let dir_path = fnamemodify(file_path, ':h')
    call mkdir(dir_path, 'p')
    
    let view_name = split(module_name, '\.')[-1]
    let liveview_content = [
      \ 'defmodule ' . module_name . ' do',
      \ '  use Phoenix.LiveView',
      \ '',
      \ '  @impl true',
      \ '  def mount(_params, _session, socket) do',
      \ '    {:ok, socket}',
      \ '  end',
      \ '',
      \ '  @impl true',
      \ '  def render(assigns) do',
      \ '    ~H"""',
      \ '    <div>',
      \ '      <h1>' . view_name . ' LiveView</h1>',
      \ '    </div>',
      \ '    """',
      \ '  end',
      \ 'end'
    \ ]
    
    call writefile(liveview_content, file_path)
    execute 'edit ' . file_path
    echo 'Created LiveView: ' . module_name
  endif
endfunction
]])

-- Mapeos para crear estructuras Elixir
map("n", "<leader>em", ":call ElixirCreateModule()<CR>", opts)
map("n", "<leader>eg", ":call ElixirCreateGenServer()<CR>", opts)
map("n", "<leader>elv", ":call PhoenixCreateLiveView()<CR>", opts)

-- ========================================
-- 🎯 ATAJOS ESPECÍFICOS PARA ELIXIR/PHOENIX
-- ========================================

-- Ejecutar comandos Mix
map("n", "<leader>mt", ":!mix test<CR>", opts)
map("n", "<leader>mT", ":!mix test %<CR>", opts) -- Test archivo actual
map("n", "<leader>mc", ":!mix compile<CR>", opts)
map("n", "<leader>mf", ":!mix format %<CR>", opts) -- Formatear archivo actual
map("n", "<leader>mF", ":!mix format<CR>", opts) -- Formatear proyecto
map("n", "<leader>md", ":!mix deps.get<CR>", opts)
map("n", "<leader>mr", ":!iex -S mix<CR>", opts) -- Iniciar IEx con el proyecto

-- Comandos Phoenix específicos
map("n", "<leader>ps", ":!mix phx.server<CR>", opts) -- Iniciar servidor Phoenix
map("n", "<leader>pr", ":!mix phx.routes<CR>", opts) -- Ver rutas
map("n", "<leader>pm", ":!mix ecto.migrate<CR>", opts) -- Ejecutar migraciones
map("n", "<leader>pR", ":!mix ecto.rollback<CR>", opts) -- Rollback migraciones

-- Navegación rápida en proyectos Elixir/Phoenix
map("n", "<leader>ec", ":Telescope find_files cwd=lib/<CR>", opts) -- Buscar en lib/
map("n", "<leader>et", ":Telescope find_files cwd=test/<CR>", opts) -- Buscar en test/
map("n", "<leader>ew", ":Telescope find_files cwd=lib/*_web<CR>", opts) -- Buscar en *_web/
map("n", "<leader>es", ":Telescope find_files cwd=priv/repo<CR>", opts) -- Buscar en schemas/migrations

-- ========================================
-- TUS KEYMAPS ORIGINALES (CONTINUACIÓN)
-- ========================================

-- Atajos para Navegación de directorios
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", opts) -- Abrir/cerrar NvimTree
map("n", "<leader>pp", ":Telescope projects<CR>", opts) -- Abrir proyectos recientes

-- Atajos para Git (preservados como estaban)
map("n", "<leader>gs", ":Telescope git_status<CR>", opts)
map("n", "<leader>gc", ":call GitCommitWithMessagePrompt()<CR>", opts)
map("n", "<leader>gp", ":Git push<CR>", opts)
map("n", "<leader>gl", ":Git pull<CR>", opts)
map("n", "<leader>gb", ":Telescope git_branches<CR>", opts)
map("n", "<leader>gco", ":Git checkout ", opts)
map("n", "<leader>ga", ":call CustomGitAdd()<CR>", opts)
map("n", "<leader>gr", ":Git reset <CR>", opts)
map("n", "<leader>grs", ":Git reset --soft HEAD~1<CR>", opts)
map("n", "<leader>gm", ":Git merge ", opts)
map("n", "<leader>gt", ":Git tag ", opts)
map("n", "<leader>gbl", ":Git blame<CR>", opts)
map("n", "<leader>gcb", ":call CreateGitBranch()<CR>", opts)
map("n", "<leader>gdb", ":call DeleteGitBranch()<CR>", opts)

-- Diffview keymaps
map("n", "<leader>dv", ":call OpenDiffviewWithBranch()<CR>", opts)
map("n", "<leader>dq", ":DiffviewClose<CR>", opts)
map("n", "<leader>dn", ":DiffviewNextFile<CR>", opts)
map("n", "<leader>dp", ":DiffviewPrevFile<CR>", opts)
map("n", "<leader>dj", ":DiffviewNextHunk<CR>", opts)
map("n", "<leader>dk", ":DiffviewPrevHunk<CR>", opts)

-- Atajos para REST.nvim
map("n", "<leader>rr", ":Rest run<CR>", opts)
map("n", "<leader>rp", ":Rest run last<CR>", opts)
map("n", "<leader>re", ":Rest run<CR>", opts)

-- Teclas para abrir y cerrar todos los folds
map("n", "<leader>fo", ":foldopen!<CR>", opts)
map("n", "<leader>fc", ":foldclose!<CR>", opts)

-- Configuración de teclas para Emmet
map("n", "<C-Z>", "<Plug>(emmet-expand-abbr)", opts)
map("i", "<C-Z>", "<Plug>(emmet-expand-abbr)", opts)

-- Mapeos para Laravel
map("n", "<leader>pl", ":Laravel<CR>", opts)

-- Mapeos para Symfony
map("n", "<leader>ps", ":!symfony server:start<CR>", opts)
map("n", "<leader>pc", ":!symfony console<CR>", opts)

-- Formateo
map("n", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format code" })
map("v", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format selection" })

-- Frontend keymaps (preservados)
map("n", "<leader>fee", ":EslintFixAll<CR>", opts)
map(
	"n",
	"<leader>fet",
	':lua require("telescope.builtin").find_files({prompt_title = "Tests", cwd = "tests", path_display = { "smart" }})<CR>',
	opts
)
map(
	"n",
	"<leader>fec",
	':lua require("telescope.builtin").find_files({prompt_title = "Components", cwd = "src/components", path_display = { "smart" }})<CR>',
	opts
)
map(
	"n",
	"<leader>fep",
	':lua require("telescope.builtin").find_files({prompt_title = "Pages", cwd = "src/pages", path_display = { "smart" }})<CR>',
	opts
)
map(
	"n",
	"<leader>fes",
	':lua require("telescope.builtin").find_files({prompt_title = "Styles", cwd = "src/styles", path_display = { "smart" }})<CR>',
	opts
)

map("n", "<leader>tso", '<cmd>lua vim.lsp.buf.code_action({context = {only = {"source.organizeImports"}}})<CR>', opts)
map("n", "<leader>tsr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- HTML Server
map("n", "<leader>hss", ":LiveServerStart<CR>", opts)
map("n", "<leader>hsx", ":LiveServerStop<CR>", opts)

-- Testing Frontend
map("n", "<leader>ftf", ":TestFile<CR>", opts)
map("n", "<leader>ftn", ":TestNearest<CR>", opts)
map("n", "<leader>ftl", ":TestLast<CR>", opts)
map("n", "<leader>ftv", ":TestVisit<CR>", opts)

-- Emmet alternativas
map("n", "<C-y>e", "<plug>(emmet-expand-abbr)", { silent = true })
map("i", "<C-y>e", "<plug>(emmet-expand-abbr)", { silent = true })

-- NPM scripts
map("n", "<leader>nps", ':lua require("package-info").show()<CR>', opts)
map("n", "<leader>npd", ":term npm run dev<CR>", opts)
map("n", "<leader>npb", ":term npm run build<CR>", opts)
map("n", "<leader>npt", ":term npm test<CR>", opts)
map("n", "<leader>npi", ":term npm install<CR>", opts)

-- Búsquedas Frontend
map(
	"n",
	"<leader>fef",
	':lua require("telescope.builtin").find_files({prompt_title="Frontend Files", file_ignore_patterns={}, hidden=true})<CR>',
	opts
)
map(
	"n",
	"<leader>feg",
	':lua require("telescope.builtin").live_grep({prompt_title="Frontend Grep", additional_args=function() return {"--no-ignore"} end})<CR>',
	opts
)

-- React snippets
map("n", "<leader>rsf", "irfc<Tab>", { noremap = false })
map("n", "<leader>rss", "irus<Tab>", { noremap = false })
map("n", "<leader>rse", "irue<Tab>", { noremap = false })
map("n", "<leader>rsc", "iruc<Tab>", { noremap = false })

-- vim-projectionist
map("n", "<leader>pa", ":A<CR>", opts)
map("n", "<leader>ps", ":AS<CR>", opts)
map("n", "<leader>pv", ":AV<CR>", opts)
map("n", "<leader>pr", ":R<CR>", opts)

-- Documentos y buffers
map("n", "<leader>br", ":Telescope oldfiles<CR>", opts)
map("n", "<leader>bb", ":Telescope buffers<CR>", opts)
map("n", "<leader>bR", ":Telescope oldfiles<CR><C-v>", opts)
map("n", "<leader>bB", ":Telescope buffers<CR><C-v>", opts)

-- Buscar en buffers
map(
	"n",
	"<leader>sb",
	':lua require("telescope.builtin").live_grep({ grep_open_files = true, prompt_title = "Grep en Buffers Abiertos" })<CR>',
	opts
)
map("n", "<leader>sB", ":Telescope current_buffer_fuzzy_find<CR>", opts)

-- React component creation (preservado)
vim.cmd([[
  command! -nargs=1 ReactComponent lua ReactCreateComponent(<f-args>)
  command! -nargs=1 ReactPage lua ReactCreatePage(<f-args>)
]])

vim.api.nvim_exec(
	[[
  function! ReactCreateComponent(name)
    let l:dir = "src/components/" . a:name
    call mkdir(l:dir, "p")

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

    let l:css_file = l:dir . "/" . a:name . ".css"
    call writefile([
      \ "." . tolower(a:name) . " {",
      \ "  padding: 20px;",
      \ "  margin: 10px;",
      \ "}"
    \], l:css_file)

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

    let l:css_file = l:dir . "/" . a:name . ".css"
    call writefile([
      \ "." . tolower(a:name) . "-page {",
      \ "  padding: 20px;",
      \ "  margin: 10px;",
      \ "}"
    \], l:css_file)

    let l:index_file = l:dir . "/index.js"
    call writefile([
      \ "export { default } from './" . a:name . "';"
    \], l:index_file)

    echo "Created React page: " . a:name
    execute "edit " . l:page_file
  endfunction
]],
	false
)

-- React creation shortcuts
map("n", "<leader>rcc", ":ReactComponent ", { noremap = true })
map("n", "<leader>rcp", ":ReactPage ", { noremap = true })

-- Splits
map("n", "<leader>sh", ":split<Space>", opts)
map("n", "<leader>sv", ":vsplit<Space>", opts)
map("n", "<leader>st", ":tabnew<Space>", opts)

-- Window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Git merge conflicts (nota: cambiado de 'do' y 'dt' para evitar conflictos)
map("n", "<leader>gdo", ":diffget //2<CR>", { desc = "Get from ours" })
map("n", "<leader>gdt", ":diffget //3<CR>", { desc = "Get from theirs" })

-- LSP Diagnostics
map("n", "<leader>xc", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
map("n", "<leader>xx", '<cmd>lua require("telescope.builtin").diagnostics()<CR>', opts)
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "<leader>dl", ":lopen<CR>", opts)

-- Mostrar keymaps
map("n", "<leader>km", ":Telescope keymaps<CR>", opts)

-- ========================================
-- 📝 RESUMEN DE KEYMAPS PARA ELIXIR/PHOENIX CON AVANTE
-- ========================================
-- <leader>aa   - Preguntar a la IA (Avante Ask)
-- <leader>ac   - Abrir chat de IA
-- <leader>at   - Toggle ventana de Avante
--
-- ELIXIR CON AVANTE:
-- <leader>aer  - Refactorizar código Elixir
-- <leader>aet  - Generar tests ExUnit
-- <leader>aeo  - Optimizar para BEAM
-- <leader>aeg  - Convertir a GenServer
-- <leader>aelv - Convertir a LiveView
-- <leader>aec  - Generar contexto Phoenix
-- <leader>aed  - Buscar docs Elixir
-- <leader>aep  - Buscar docs Phoenix
-- <leader>aeh  - Buscar en Hex.pm
-- <leader>aee  - Explicar código
-- <leader>aeb  - Best practices
--
-- CREAR ESTRUCTURAS:
-- <leader>em   - Crear módulo Elixir
-- <leader>eg   - Crear GenServer
-- <leader>elv  - Crear LiveView
--
-- COMANDOS MIX:
-- <leader>mt   - mix test
-- <leader>mT   - mix test (archivo actual)
-- <leader>mc   - mix compile
-- <leader>mf   - mix format (archivo)
-- <leader>mF   - mix format (proyecto)
-- <leader>md   - mix deps.get
-- <leader>mr   - iex -S mix
--
-- PHOENIX:
-- <leader>ps   - mix phx.server
-- <leader>pr   - mix phx.routes
-- <leader>pm   - mix ecto.migrate
-- <leader>pR   - mix ecto.rollback
--
-- NAVEGACIÓN ELIXIR:
-- <leader>ec   - Buscar en lib/
-- <leader>et   - Buscar en test/
-- <leader>ew   - Buscar en *_web/
-- <leader>es   - Buscar schemas

return {}
