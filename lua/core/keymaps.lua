-- lua/core/keymaps.lua - Configuración de atajos de teclado en Neovim

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- ========================================
-- FUNCIONES AUXILIARES (Definidas al inicio)
-- ========================================

-- Funciones para Git
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

function! GitStashWithMessage()
  let l:message = input('Mensaje del stash: ')
  if l:message != ''
    execute 'Git stash push -m "' . l:message . '"'
  else
    echo 'Operación cancelada'
  endif
endfunction

function! InteractiveGitStash()
  let l:options = [
    '1. Crear stash',
    '2. Crear stash con mensaje',
    '3. Listar stashes',
    '4. Aplicar stash',
    '5. Pop stash',
    '6. Mostrar stash',
    '7. Eliminar stash',
    '8. Limpiar todos los stashes'
  ]
  
  let l:choice = inputlist(['Selecciona una opción:'] + l:options)
  
  if l:choice == 1
    execute 'Git stash'
  elseif l:choice == 2
    call GitStashWithMessage()
  elseif l:choice == 3
    execute 'Git stash list'
  elseif l:choice == 4
    let l:stash = input('Número del stash (0 para el último): ')
    if l:stash != ''
      execute 'Git stash apply stash@{' . l:stash . '}'
    else
      execute 'Git stash apply'
    endif
  elseif l:choice == 5
    let l:stash = input('Número del stash (0 para el último): ')
    if l:stash != ''
      execute 'Git stash pop stash@{' . l:stash . '}'
    else
      execute 'Git stash pop'
    endif
  elseif l:choice == 6
    let l:stash = input('Número del stash (0 para el último): ')
    if l:stash != ''
      execute 'Git stash show stash@{' . l:stash . '}'
    else
      execute 'Git stash show'
    endif
  elseif l:choice == 7
    let l:stash = input('Número del stash a eliminar: ')
    if l:stash != ''
      execute 'Git stash drop stash@{' . l:stash . '}'
    endif
  elseif l:choice == 8
    let l:confirm = input('¿Estás seguro de eliminar todos los stashes? (y/N): ')
    if l:confirm ==? 'y'
      execute 'Git stash clear'
    endif
  else
    echo 'Operación cancelada'
  endif
endfunction
]])

-- Funciones para diagnósticos
vim.cmd([[
function! ShowDiagnosticsSummary()
  lua << EOF
    local count = _G.get_diagnostics_count()
    local total = count.errors + count.warnings + count.info + count.hints
    
    if total == 0 then
      print("✅ ¡Todo limpio! Sin errores ni warnings")
      return
    end
    
    local msg = "📊 Estado del archivo:\n"
    if count.errors > 0 then
      msg = msg .. string.format("❌ %d errores\n", count.errors)
    end
    if count.warnings > 0 then
      msg = msg .. string.format("⚠️  %d warnings\n", count.warnings)
    end
    if count.info > 0 then
      msg = msg .. string.format("ℹ️  %d info\n", count.info)
    end
    if count.hints > 0 then
      msg = msg .. string.format("💡 %d hints\n", count.hints)
    end
    
    print(msg)
    
    if count.errors > 0 then
      local response = vim.fn.input("¿Ir al primer error? (y/n): ")
      if response:lower() == "y" then
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
      end
    end
EOF
endfunction

function! RefreshDiagnostics()
  lua << EOF
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.name == "elixirls" then
        vim.notify("🔄 Reiniciando ElixirLS...", vim.log.levels.INFO)
        vim.lsp.buf.refresh()
      end
    end
    
    vim.diagnostic.reset()
    
    vim.schedule(function()
      vim.lsp.buf.refresh()
      vim.notify("✅ Diagnósticos actualizados", vim.log.levels.INFO)
    end)
EOF
endfunction

function! ElixirCompileAndCheck()
  lua << EOF
    vim.notify("⚗️ Compilando proyecto Elixir...", vim.log.levels.INFO)
    
    vim.fn.jobstart("mix compile", {
      on_stdout = function(_, data)
        for _, line in ipairs(data) do
          if line:match("error") or line:match("Error") then
            vim.schedule(function()
              vim.notify("❌ " .. line, vim.log.levels.ERROR)
            end)
          elseif line:match("warning") or line:match("Warning") then
            vim.schedule(function()
              vim.notify("⚠️ " .. line, vim.log.levels.WARN)
            end)
          end
        end
      end,
      on_exit = function(_, exit_code)
        vim.schedule(function()
          if exit_code == 0 then
            vim.notify("✅ Compilación exitosa", vim.log.levels.INFO)
            vim.lsp.buf.refresh()
          else
            vim.notify("❌ Compilación falló - revisa los errores", vim.log.levels.ERROR)
            vim.defer_fn(function()
              local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
              if #diagnostics > 0 then
                vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
              end
            end, 500)
          end
        end)
      end
    })
EOF
endfunction
]])

-- Funciones para crear módulos Elixir
vim.cmd([[
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

-- Funciones para React
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

-- Funciones para buffers
function close_buffer_smart()
	local buf = vim.api.nvim_get_current_buf()
	local buf_count = #vim.tbl_filter(function(b)
		return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())

	if buf_count <= 1 then
		vim.notify("📝 No se puede cerrar el último buffer", vim.log.levels.WARN)
		return
	end

	vim.cmd("BufferLineCyclePrev")

	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = false })
			vim.notify("🗑️ Buffer cerrado", vim.log.levels.INFO)
		end
	end)
end

function goto_buffer_with_diagnostics(severity)
	local buffers = vim.api.nvim_list_bufs()
	local severity_name = severity == vim.diagnostic.severity.ERROR and "errores" or "warnings"

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
			local diagnostics = vim.diagnostic.get(buf, { severity = severity })
			if #diagnostics > 0 then
				vim.api.nvim_set_current_buf(buf)
				vim.diagnostic.goto_next({ severity = severity, buffer = buf })
				vim.notify("🎯 Saltando a buffer con " .. severity_name, vim.log.levels.INFO)
				return
			end
		end
	end

	vim.notify("✅ No hay buffers con " .. severity_name, vim.log.levels.INFO)
end

function show_buffers_diagnostics_summary()
	local buffers = vim.api.nvim_list_bufs()
	local total_errors = 0
	local total_warnings = 0
	local buffers_with_issues = {}

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
			local diagnostics = vim.diagnostic.get(buf)
			local errors = #vim.tbl_filter(function(d)
				return d.severity == vim.diagnostic.severity.ERROR
			end, diagnostics)
			local warnings = #vim.tbl_filter(function(d)
				return d.severity == vim.diagnostic.severity.WARN
			end, diagnostics)

			total_errors = total_errors + errors
			total_warnings = total_warnings + warnings

			if errors > 0 or warnings > 0 then
				local name = vim.api.nvim_buf_get_name(buf)
				local filename = vim.fn.fnamemodify(name, ":t")
				if filename == "" then
					filename = "[Sin nombre]"
				end

				table.insert(buffers_with_issues, {
					name = filename,
					errors = errors,
					warnings = warnings,
					buf = buf,
				})
			end
		end
	end

	if #buffers_with_issues == 0 then
		vim.notify("🎉 ¡Todos los buffers están limpios!", vim.log.levels.INFO)
		return
	end

	local message = "📊 Resumen de diagnósticos:\n"
	message = message .. string.format("Total: %d errores, %d warnings\n\n", total_errors, total_warnings)

	for _, buf_info in ipairs(buffers_with_issues) do
		message = message .. string.format("📄 %s: ", buf_info.name)
		if buf_info.errors > 0 then
			message = message .. string.format("❌%d ", buf_info.errors)
		end
		if buf_info.warnings > 0 then
			message = message .. string.format("⚠️%d ", buf_info.warnings)
		end
		message = message .. "\n"
	end

	print(message)

	if total_errors > 0 then
		local response = vim.fn.input("¿Ir al primer buffer con errores? (y/n): ")
		if response:lower() == "y" then
			goto_buffer_with_diagnostics(vim.diagnostic.severity.ERROR)
		end
	end
end

-- ========================================
-- MAPEOS GENERALES
-- ========================================

-- Archivo y edición
map("n", "<leader>w", ":w<CR>", opts) -- Guardar archivo
map("n", "<leader>q", ":q<CR>", opts) -- Salir de Neovim
map("n", "<C-s>", ":w<CR>", opts) -- Guardar con Ctrl + S
map("i", "<C-s>", "<Esc>:w<CR>a", opts) -- Guardar en modo inserción
map("n", "<leader>l", ":noh<CR>", opts) -- Limpiar búsqueda resaltada

-- Formateo
map("n", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format code" })
map("v", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format selection" })

-- Splits y ventanas
map("n", "<leader>sh", ":split<Space>", opts)
map("n", "<leader>sv", ":vsplit<Space>", opts)
map("n", "<leader>st", ":tabnew<Space>", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Folds
map("n", "<leader>fo", ":foldopen!<CR>", opts)
map("n", "<leader>fc", ":foldclose!<CR>", opts)

-- Emmet
map("n", "<C-Z>", "<Plug>(emmet-expand-abbr)", opts)
map("i", "<C-Z>", "<Plug>(emmet-expand-abbr)", opts)
map("n", "<C-y>e", "<plug>(emmet-expand-abbr)", { silent = true })
map("i", "<C-y>e", "<plug>(emmet-expand-abbr)", { silent = true })

-- Mostrar keymaps
map("n", "<leader>km", ":Telescope keymaps<CR>", opts)

-- ========================================
-- NAVEGACIÓN DE ARCHIVOS Y BÚSQUEDAS
-- ========================================

-- NvimTree
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", opts)

-- Telescope básico
map("n", "<leader>ff", ":Telescope find_files no_ignore=true<CR>", opts)
map("n", "<leader>fg", ":Telescope live_grep no_ignore=true<CR>", opts)
map("n", "<leader>fb", ":Telescope buffers<CR>", opts)
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
map("n", "<leader>fm", ":Telescope marks<CR>", opts)
map("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)

-- Telescope con splits
map("n", "<leader>fs", ":Telescope find_files<CR><C-x>", opts)
map("n", "<leader>fv", ":Telescope find_files<CR><C-v>", opts)
map("n", "<leader>ft", ":Telescope find_files<CR><C-t>", opts)

-- Proyectos
map("n", "<leader>pp", ":Telescope projects<CR>", opts)

-- vim-projectionist
map("n", "<leader>pa", ":A<CR>", opts)
map("n", "<leader>ps", ":AS<CR>", opts)
map("n", "<leader>pv", ":AV<CR>", opts)
map("n", "<leader>pr", ":R<CR>", opts)

-- ========================================
-- LSP Y DIAGNÓSTICOS
-- ========================================

-- LSP básico
map("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts)
map("n", "gr", ":lua vim.lsp.buf.references()<CR>", opts)
map("n", "K", ":lua vim.lsp.buf.hover()<CR>", opts)
map("n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", opts)
map("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", opts)

-- Diagnósticos principales
map("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float({ scope = 'cursor', border = 'rounded' })<CR>", opts)
map("n", "<leader>E", "<cmd>lua vim.diagnostic.open_float({ scope = 'buffer', border = 'rounded' })<CR>", opts)

-- Navegación de diagnósticos
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "[e", "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>", opts)
map("n", "]e", "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>", opts)
map("n", "[w", "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>", opts)
map("n", "]w", "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>", opts)

-- Listas de diagnósticos
map("n", "<leader>xx", "<cmd>Telescope diagnostics bufnr=0 severity_limit=1<CR>", opts)
map("n", "<leader>xX", "<cmd>Telescope diagnostics<CR>", opts)
map("n", "<leader>xe", "<cmd>lua vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })<CR>", opts)
map("n", "<leader>xw", "<cmd>lua vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.WARN })<CR>", opts)
map("n", "<leader>xi", ":DiagnosticsInfo<CR>", opts)
map("n", "<leader>xf", "<cmd>lua vim.diagnostic.open_float({ scope = 'line', border = 'rounded' })<CR>", opts)

-- Funciones de diagnóstico
map("n", "<leader>ds", ":call ShowDiagnosticsSummary()<CR>", opts)
map("n", "<leader>dr", ":call RefreshDiagnostics()<CR>", opts)
map("n", "<leader>dl", ":lopen<CR>", opts)

-- Quickfix
map("n", "<leader>qo", ":copen<CR>", opts)
map("n", "<leader>qc", ":cclose<CR>", opts)
map("n", "<leader>qn", ":cnext<CR>", opts)
map("n", "<leader>qp", ":cprev<CR>", opts)
map("n", "<leader>qf", ":cfirst<CR>", opts)
map("n", "<leader>ql", ":clast<CR>", opts)

-- Location list
map("n", "<leader>lo", ":lopen<CR>", opts)
map("n", "<leader>lc", ":lclose<CR>", opts)
map("n", "<leader>ln", ":lnext<CR>", opts)
map("n", "<leader>lp", ":lprev<CR>", opts)

-- ========================================
-- GIT
-- ========================================

-- Git básico
map("n", "<leader>gs", ":Telescope git_status<CR>", opts)
map("n", "<leader>gc", ":call GitCommitWithMessagePrompt()<CR>", opts)
map("n", "<leader>gp", ":Git push<CR>", opts)
map("n", "<leader>gl", ":Git pull<CR>", opts)
map("n", "<leader>gb", ":Telescope git_branches<CR>", opts)
map("n", "<leader>ga", ":call CustomGitAdd()<CR>", opts)
map("n", "<leader>gbl", ":Git blame<CR>", opts)

-- Git branches
map("n", "<leader>gco", ":Git checkout ", opts)
map("n", "<leader>gcb", ":call CreateGitBranch()<CR>", opts)
map("n", "<leader>gdb", ":call DeleteGitBranch()<CR>", opts)

-- Git reset
map("n", "<leader>gr", ":Git reset <CR>", opts)
map("n", "<leader>grs", ":Git reset --soft HEAD~1<CR>", opts)

-- Git merge
map("n", "<leader>gm", ":Git merge ", opts)
map("n", "<leader>gdo", ":diffget //2<CR>", { desc = "Get from ours" })
map("n", "<leader>gdt", ":diffget //3<CR>", { desc = "Get from theirs" })

-- Git tag
map("n", "<leader>gt", ":Git tag ", opts)

-- Git stash
map("n", "<leader>gst", ":Git stash<CR>", opts)
map("n", "<leader>gstm", ":call GitStashWithMessage()<CR>", opts)
map("n", "<leader>gsl", ":Git stash list<CR>", opts)
map("n", "<leader>gsa", ":Git stash apply<CR>", opts)
map("n", "<leader>gsp", ":Git stash pop<CR>", opts)
map("n", "<leader>gsd", ":Git stash drop<CR>", opts)
map("n", "<leader>gsw", ":Git stash show<CR>", opts)
map("n", "<leader>gsc", ":Git stash clear<CR>", opts)
map("n", "<leader>gss", ":call InteractiveGitStash()<CR>", opts)

-- Diffview
map("n", "<leader>dv", ":call OpenDiffviewWithBranch()<CR>", opts)
map("n", "<leader>dq", ":DiffviewClose<CR>", opts)
map("n", "<leader>dn", ":DiffviewNextFile<CR>", opts)
map("n", "<leader>dp", ":DiffviewPrevFile<CR>", opts)
map("n", "<leader>dj", ":DiffviewNextHunk<CR>", opts)
map("n", "<leader>dk", ":DiffviewPrevHunk<CR>", opts)

-- ========================================
-- BUFFERS
-- ========================================

-- Navegación básica (si tienes BufferLine)
map("n", "<Tab>", ":BufferLineCycleNext<CR>", opts)
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", opts)
map("n", "<leader>bp", ":BufferLinePick<CR>", opts)
map("n", "<leader>bc", ":BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>", opts)
map("n", "<leader>bq", ":BufferLineClose<CR>", opts)

-- Navegación por números
map("n", "<leader>b1", ":BufferLineGoToBuffer 1<CR>", opts)
map("n", "<leader>b2", ":BufferLineGoToBuffer 2<CR>", opts)
map("n", "<leader>b3", ":BufferLineGoToBuffer 3<CR>", opts)
map("n", "<leader>b4", ":BufferLineGoToBuffer 4<CR>", opts)
map("n", "<leader>b5", ":BufferLineGoToBuffer 5<CR>", opts)
map("n", "<leader>b6", ":BufferLineGoToBuffer 6<CR>", opts)
map("n", "<leader>b7", ":BufferLineGoToBuffer 7<CR>", opts)
map("n", "<leader>b8", ":BufferLineGoToBuffer 8<CR>", opts)
map("n", "<leader>b9", ":BufferLineGoToBuffer 9<CR>", opts)

-- Gestión de buffers
map("n", "<leader>bP", ":BufferLineTogglePin<CR>", opts)
map("n", "<leader>b>", ":BufferLineMoveNext<CR>", opts)
map("n", "<leader>b<", ":BufferLineMovePrev<CR>", opts)
map("n", "<leader>bl", ":BufferLineCloseLeft<CR>", opts)
map("n", "<leader>br", ":BufferLineCloseRight<CR>", opts)
map("n", "<leader>bd", "<cmd>lua close_buffer_smart()<CR>", opts)

-- Diagnósticos en buffers
map("n", "<leader>be", "<cmd>lua goto_buffer_with_diagnostics(vim.diagnostic.severity.ERROR)<CR>", opts)
map("n", "<leader>bw", "<cmd>lua goto_buffer_with_diagnostics(vim.diagnostic.severity.WARN)<CR>", opts)
map("n", "<leader>bs", "<cmd>lua show_buffers_diagnostics_summary()<CR>", opts)

-- ========================================
-- ELIXIR/PHOENIX
-- ========================================

-- Mix commands
map("n", "<leader>mt", ":!mix test<CR>", opts)
map("n", "<leader>mT", ":!mix test %<CR>", opts)
map("n", "<leader>mc", ":!mix compile<CR>", opts)
map("n", "<leader>mf", ":!mix format %<CR>", opts)
map("n", "<leader>mF", ":!mix format<CR>", opts)
map("n", "<leader>md", ":!mix deps.get<CR>", opts)
map("n", "<leader>mr", ":!iex -S mix<CR>", opts)

-- Mix compile avanzado
map("n", "<leader>mcc", ":!mix compile --warnings-as-errors<CR>", opts)
map("n", "<leader>mcd", ":!mix deps.compile --force<CR>", opts)
map("n", "<leader>mcf", ":!mix format --check-formatted<CR>", opts)
map("n", "<leader>mxx", ":call ElixirCompileAndCheck()<CR>", opts)

-- Mix test avanzado
map("n", "<leader>mte", ":!mix test --failed --max-failures=1<CR>", opts)
map("n", "<leader>mtv", ":!mix test --trace --verbose<CR>", opts)
map("n", "<leader>mtw", ":!mix test.watch --stale<CR>", opts)

-- Análisis de código
map("n", "<leader>mce", ":!mix credo --strict --all<CR>", opts)
map("n", "<leader>mcs", ":!mix credo suggest --help<CR>", opts)
map("n", "<leader>mcd", ":!mix dialyzer --format dialyzer<CR>", opts)

-- Logs y limpieza
map("n", "<leader>mll", ":!tail -f _build/dev/lib/*/ebin/*.log<CR>", opts)
map("n", "<leader>mlc", ":!mix clean && mix compile<CR>", opts)

-- Phoenix
map("n", "<leader>ps", ":!mix phx.server<CR>", opts)
map("n", "<leader>pr", ":!mix phx.routes<CR>", opts)
map("n", "<leader>pm", ":!mix ecto.migrate<CR>", opts)
map("n", "<leader>pR", ":!mix ecto.rollback<CR>", opts)

-- Crear estructuras
map("n", "<leader>em", ":call ElixirCreateModule()<CR>", opts)
map("n", "<leader>eg", ":call ElixirCreateGenServer()<CR>", opts)
map("n", "<leader>elv", ":call PhoenixCreateLiveView()<CR>", opts)

-- Navegación Elixir
map("n", "<leader>ec", ":Telescope find_files cwd=lib/<CR>", opts)
map("n", "<leader>et", ":Telescope find_files cwd=test/<CR>", opts)
map("n", "<leader>ew", ":Telescope find_files cwd=lib/*_web<CR>", opts)
map("n", "<leader>es", ":Telescope find_files cwd=priv/repo<CR>", opts)

-- ========================================
-- AVANTE.NVIM (IA)
-- ========================================

-- Básicos
map("n", "<leader>aa", ":AvanteAsk ", opts)
map("v", "<leader>aa", ":AvanteAsk ", opts)
map("n", "<leader>ac", ":AvanteChat<CR>", opts)
map("n", "<leader>at", ":AvanteToggle<CR>", opts)

-- Elixir con Avante
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

-- Documentación
map("n", "<leader>aed", ":AvanteAsk Busca en la documentación de Elixir sobre ", opts)
map("n", "<leader>aep", ":AvanteAsk Busca en la documentación de Phoenix sobre ", opts)
map("n", "<leader>aeh", ":AvanteAsk Busca en Hex.pm paquetes para ", opts)

-- Explicaciones
map("n", "<leader>aee", ":AvanteAsk Explica este código Elixir paso a paso<CR>", opts)
map("v", "<leader>aee", ":AvanteAsk Explica este código Elixir paso a paso<CR>", opts)
map("n", "<leader>aeb", ":AvanteAsk ¿Cuáles son las mejores prácticas para esto en Elixir?<CR>", opts)

-- ========================================
-- FRONTEND
-- ========================================

-- ESLint y TypeScript
map("n", "<leader>fee", ":EslintFixAll<CR>", opts)
map("n", "<leader>tso", '<cmd>lua vim.lsp.buf.code_action({context = {only = {"source.organizeImports"}}})<CR>', opts)
map("n", "<leader>tsr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- Navegación Frontend
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

-- HTML Server
map("n", "<leader>hss", ":LiveServerStart<CR>", opts)
map("n", "<leader>hsx", ":LiveServerStop<CR>", opts)

-- Testing Frontend
map("n", "<leader>ftf", ":TestFile<CR>", opts)
map("n", "<leader>ftn", ":TestNearest<CR>", opts)
map("n", "<leader>ftl", ":TestLast<CR>", opts)
map("n", "<leader>ftv", ":TestVisit<CR>", opts)

-- NPM
map("n", "<leader>nps", ':lua require("package-info").show()<CR>', opts)
map("n", "<leader>npd", ":term npm run dev<CR>", opts)
map("n", "<leader>npb", ":term npm run build<CR>", opts)
map("n", "<leader>npt", ":term npm test<CR>", opts)
map("n", "<leader>npi", ":term npm install<CR>", opts)

-- React
map("n", "<leader>rcc", ":ReactComponent ", { noremap = true })
map("n", "<leader>rcp", ":ReactPage ", { noremap = true })
map("n", "<leader>rsf", "irfc<Tab>", { noremap = false })
map("n", "<leader>rss", "irus<Tab>", { noremap = false })
map("n", "<leader>rse", "irue<Tab>", { noremap = false })
map("n", "<leader>rsc", "iruc<Tab>", { noremap = false })

-- ========================================
-- OTROS FRAMEWORKS
-- ========================================

-- Laravel
map("n", "<leader>pl", ":Laravel<CR>", opts)

-- Symfony
map("n", "<leader>ps", ":!symfony server:start<CR>", opts)
map("n", "<leader>pc", ":!symfony console<CR>", opts)

-- REST.nvim
map("n", "<leader>rr", ":Rest run<CR>", opts)
map("n", "<leader>rp", ":Rest run last<CR>", opts)
map("n", "<leader>re", ":Rest run<CR>", opts)

-- ========================================
-- COMANDOS DE USUARIO
-- ========================================

-- React
vim.cmd([[
  command! -nargs=1 ReactComponent lua ReactCreateComponent(<f-args>)
  command! -nargs=1 ReactPage lua ReactCreatePage(<f-args>)
]])

-- Buffers
vim.api.nvim_create_user_command("BufferDiagnosticsSummary", show_buffers_diagnostics_summary, {
	desc = "Muestra resumen de diagnósticos de todos los buffers",
})

vim.api.nvim_create_user_command("BufferGotoErrors", function()
	goto_buffer_with_diagnostics(vim.diagnostic.severity.ERROR)
end, {
	desc = "Va al buffer con errores",
})

vim.api.nvim_create_user_command("BufferGotoWarnings", function()
	goto_buffer_with_diagnostics(vim.diagnostic.severity.WARN)
end, {
	desc = "Va al buffer con warnings",
})

-- ========================================
-- RESUMEN DE KEYMAPS POR CATEGORÍA
-- ========================================
--
-- GENERAL:
-- <leader>w      → Guardar
-- <leader>q      → Salir
-- <leader>l      → Limpiar búsqueda
-- <leader>f      → Formatear código
-- <leader>km     → Ver todos los keymaps
--
-- NAVEGACIÓN:
-- <leader>e      → Toggle NvimTree
-- <leader>ff     → Buscar archivos
-- <leader>fg     → Buscar texto
-- <leader>fb     → Buscar buffers
--
-- LSP/DIAGNÓSTICOS:
-- gd             → Ir a definición
-- gr             → Referencias
-- K              → Hover
-- <leader>rn     → Renombrar
-- <leader>ca     → Code action
-- <leader>e      → Error en cursor
-- <leader>xx     → Lista errores
-- [d/]d          → Navegar diagnósticos
--
-- GIT:
-- <leader>gs     → Status
-- <leader>gc     → Commit
-- <leader>gp     → Push
-- <leader>gl     → Pull
-- <leader>gb     → Branches
-- <leader>gst    → Stash
--
-- BUFFERS:
-- <leader>b1-9   → Ir a buffer X
-- <leader>bd     → Cerrar buffer
-- <leader>be     → Buffer con errores
--
-- ELIXIR:
-- <leader>mt     → mix test
-- <leader>mc     → mix compile
-- <leader>em     → Crear módulo
-- <leader>eg     → Crear GenServer
--
-- AVANTE (IA):
-- <leader>aa     → Preguntar
-- <leader>ac     → Chat
-- <leader>aer    → Refactorizar Elixir
-- <leader>aet    → Generar tests
--
-- FRONTEND:
-- <leader>fee    → ESLint fix
-- <leader>rcc    → Crear componente React
-- <leader>npd    → npm run dev
--
-- ========================================

return {}
