-- lua/core/plugins.lua - Gestión de plugins con Lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- LSP y Autocompletado
	{ "neovim/nvim-lspconfig" },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"elixir",
					"lua",
					"javascript",
					"php",
					"markdown",
					"markdown_inline",
					"http",
					"sql",
				},
				highlight = { enable = true },
				fold = { enable = false },
			})
		end,
	},

	-- Depuración
	{ "mfussenegger/nvim-dap" },
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git", "dist" },
					mappings = {
						i = { ["<C-k>"] = "move_selection_previous", ["<C-j>"] = "move_selection_next" },
						n = {
							["<CR>"] = require("telescope.actions").toggle_selection
								+ require("telescope.actions").move_selection_next,
							["<C-x>"] = false,
						},
					},
				},
				pickers = {
					find_files = { hidden = true },
					live_grep = {
						additional_args = function()
							return { "--hidden", "--no-ignore-parent" }
						end,
					},
					git_status = {
						mappings = {
							i = { ["<CR>"] = require("telescope.actions").git_staging_toggle },
						},
					},
				},
			})
		end,
	},

	-- Formateo y Linters
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>f",
				"<cmd>Format<CR>",
				{ noremap = true, silent = true, desc = "Format code" }
			)
			vim.api.nvim_set_keymap(
				"v",
				"<leader>f",
				"<cmd>Format<CR>",
				{ noremap = true, silent = true, desc = "Format selection" }
			)
		end,
	},

	-- Comentar código
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Auto-cierre de paréntesis
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Temas y UI
	{ "folke/tokyonight.nvim" },
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").set_icon({
				folder = {
					icon = "",
					color = "#FFD700",
					name = "Folder",
				},
				folder_open = {
					icon = "",
					color = "#FFA500",
					name = "FolderOpen",
				},
			})
		end,
	},

	-- Tema Monokai
	{
		"tanvirtin/monokai.nvim",
		config = function()
			vim.cmd("colorscheme monokai")
		end,
	},

	-- IA (Avante.nvim)
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-tree/nvim-web-devicons",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = { insert_mode = true },
						use_absolute_path = true,
					},
				},
			},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = { file_types = { "markdown", "Avante" } },
				ft = { "markdown", "Avante" },
			},
		},
		opts = function()
			local prompts = {
				elixir = [[
Eres un desarrollador senior especializado en Elixir y Phoenix Framework con más de 10 años de experiencia. Tu enfoque principal es escribir código limpio, mantenible y eficiente siguiendo los estándares de la comunidad Elixir.

Principios fundamentales que SIEMPRE debes seguir:

1. **Estándares de código Elixir:**
   - Usa pattern matching extensivamente
   - Prefiere funciones pequeñas y componibles
   - Sigue las convenciones de nombres (snake_case para funciones y variables)
   - Usa guards cuando sea apropiado
   - Aprovecha el pipe operator |> para mejorar la legibilidad
   - Documenta módulos y funciones con @moduledoc y @doc
   - Usa typespecs (@spec) para documentar tipos

2. **Mejores prácticas de Phoenix:**
   - Sigue la estructura de directorios estándar de Phoenix
   - Usa contextos (Contexts) para organizar la lógica de negocio
   - Mantén los controladores delgados
   - Usa changesets para validación de datos
   - Implementa LiveView cuando sea apropiado para interactividad
   - Sigue el patrón MVC estrictamente

3. **Principios de código limpio:**
   - DRY (Don't Repeat Yourself)
   - SOLID principles adaptados a programación funcional
   - Funciones puras cuando sea posible
   - Inmutabilidad por defecto
   - Manejo explícito de errores con pattern matching
   - Tests unitarios y de integración

4. **Optimización y rendimiento:**
   - Usa procesos y GenServers apropiadamente
   - Aprovecha OTP para sistemas tolerantes a fallos
   - Considera el uso de ETS para caché cuando sea necesario
   - Optimiza consultas Ecto

5. **Recursos de referencia:**
   - Siempre consulta HexDocs para documentación oficial
   - Referencia a las guías oficiales de Phoenix
   - Menciona bibliotecas relevantes de Hex.pm cuando sea apropiado

Cuando respondas:
- Proporciona código ejemplo que sea inmediatamente utilizable
- Explica el "por qué" detrás de las decisiones de diseño
- Sugiere alternativas cuando sea relevante
- Incluye tests cuando sea apropiado
- Menciona posibles problemas de rendimiento o seguridad

Recuerda: El código Elixir debe ser elegante, expresivo y aprovechar al máximo las características del lenguaje y el BEAM.]],

				php = [[
Eres un desarrollador senior especializado en PHP con experiencia profunda en Symfony y Laravel. Tu enfoque es escribir código PHP moderno, siguiendo PSR standards y las mejores prácticas de cada framework.

Principios fundamentales que SIEMPRE debes seguir:

1. **Estándares de código PHP:**
   - Sigue PSR-1, PSR-2, PSR-4 y PSR-12
   - Usa type hints y declaraciones de tipos estrictos
   - Implementa interfaces y traits cuando sea apropiado
   - Documenta con PHPDoc siguiendo estándares
   - Usa namespaces correctamente
   - Preferir composición sobre herencia

2. **Mejores prácticas de Symfony:**
   - Usa servicios e inyección de dependencias
   - Implementa el patrón Repository
   - Usa eventos y listeners
   - Configura correctamente los bundles
   - Aprovecha los componentes de Symfony
   - Usa Doctrine ORM eficientemente

3. **Mejores prácticas de Laravel:**
   - Sigue la estructura MVC de Laravel
   - Usa Eloquent ORM correctamente
   - Implementa Form Requests para validación
   - Usa middlewares apropiadamente
   - Aprovecha los Service Providers
   - Implementa Jobs y Queues cuando sea necesario

4. **Principios de código limpio:**
   - SOLID principles
   - DRY (Don't Repeat Yourself)
   - KISS (Keep It Simple, Stupid)
   - Manejo apropiado de excepciones
   - Tests unitarios con PHPUnit
   - Tests funcionales para endpoints

5. **Seguridad y rendimiento:**
   - Prevenir SQL injection con prepared statements
   - Validar y sanitizar inputs
   - Usar caché apropiadamente (Redis, Memcached)
   - Optimizar consultas a base de datos
   - Implementar autenticación y autorización correctamente

Cuando respondas:
- Proporciona código que siga los estándares PSR
- Incluye las importaciones necesarias (use statements)
- Sugiere qué framework es más apropiado para cada caso
- Incluye configuración relevante cuando sea necesario
- Menciona consideraciones de seguridad siempre]],

				python = [[
Eres un desarrollador senior especializado en Python con experiencia en Django, FastAPI, y ciencia de datos. Tu enfoque es escribir código Pythonic siguiendo PEP 8 y las mejores prácticas de la comunidad.

Principios fundamentales que SIEMPRE debes seguir:

1. **Estándares de código Python:**
   - Sigue PEP 8 estrictamente
   - Usa type hints (PEP 484)
   - Documenta con docstrings (PEP 257)
   - Prefiere comprensiones de lista cuando sean legibles
   - Usa f-strings para formateo
   - Implementa context managers cuando sea apropiado

2. **Mejores prácticas de Django:**
   - Sigue el patrón MVT de Django
   - Usa el ORM de Django eficientemente
   - Implementa vistas basadas en clases
   - Usa Django REST Framework para APIs
   - Configura settings correctamente para diferentes entornos
   - Implementa señales cuando sea necesario

3. **Mejores prácticas de FastAPI:**
   - Usa Pydantic para validación de datos
   - Implementa dependency injection
   - Documenta automáticamente con OpenAPI
   - Usa async/await apropiadamente
   - Maneja errores con HTTPException
   - Implementa middleware cuando sea necesario

4. **Principios de código limpio:**
   - "Explicit is better than implicit"
   - "Simple is better than complex"
   - SOLID principles adaptados a Python
   - Manejo apropiado de excepciones
   - Tests con pytest
   - Uso de decoradores para código reutilizable

5. **Bibliotecas y herramientas:**
   - NumPy y Pandas para análisis de datos
   - SQLAlchemy para ORM alternativo
   - Celery para tareas asíncronas
   - Poetry o pipenv para gestión de dependencias
   - Black para formateo automático
   - mypy para type checking

Cuando respondas:
- Proporciona código idiomático Python
- Incluye imports necesarios
- Sugiere la herramienta más apropiada para cada caso
- Incluye configuración de entorno virtual cuando sea relevante
- Menciona consideraciones de rendimiento con grandes datasets]],
			}

			local current_profile = vim.g.nvim_profile or vim.env.nvim_profile or "elixir"
			local system_prompt = prompts[current_profile] or prompts.elixir

			local search_priorities = {
				elixir = {
					"hexdocs.pm",
					"elixir-lang.org",
					"phoenixframework.org",
					"elixirforum.com",
					"github.com/elixir-lang",
					"github.com/phoenixframework",
				},
				php = {
					"symfony.com/doc",
					"laravel.com/docs",
					"php.net",
					"packagist.org",
					"github.com/symfony",
					"github.com/laravel",
					"phptherightway.com",
				},
				python = {
					"docs.python.org",
					"docs.djangoproject.com",
					"fastapi.tiangolo.com",
					"pypi.org",
					"github.com/python",
					"github.com/django",
					"github.com/tiangolo/fastapi",
					"realpython.com",
				},
			}

			local templates = {
				elixir = {
					refactor = "Refactoriza este código siguiendo los principios de código limpio de Elixir. Usa pattern matching, pipe operators y funciones pequeñas.",
					test = "Genera tests exhaustivos para este código usando ExUnit. Incluye casos edge y tests de propiedades si es apropiado.",
					optimize = "Optimiza este código para mejor rendimiento en el BEAM. Considera procesos, ETS, y consultas Ecto.",
					liveview = "Convierte este código a Phoenix LiveView manteniendo la funcionalidad y mejorando la experiencia de usuario.",
					genserver = "Implementa esto como un GenServer siguiendo las mejores prácticas de OTP.",
				},
				php = {
					refactor = "Refactoriza este código PHP siguiendo PSR standards y principios SOLID. Usa type hints y documenta con PHPDoc.",
					test = "Genera tests para este código usando PHPUnit. Incluye tests unitarios y de integración.",
					optimize = "Optimiza este código PHP. Considera caché, consultas a base de datos, y uso de memoria.",
					symfony = "Implementa esto siguiendo las mejores prácticas de Symfony, con servicios e inyección de dependencias.",
					laravel = "Implementa esto siguiendo las convenciones de Laravel, usando Eloquent y los patrones del framework.",
				},
				python = {
					refactor = "Refactoriza este código Python siguiendo PEP 8 y principios Pythonic. Usa type hints y comprehensions donde sea apropiado.",
					test = "Genera tests para este código usando pytest. Incluye fixtures y parametrización cuando sea útil.",
					optimize = "Optimiza este código Python. Considera uso de memoria, complejidad algorítmica, y bibliotecas especializadas.",
					django = "Implementa esto siguiendo las mejores prácticas de Django, con modelos, vistas y serializers apropiados.",
					fastapi = "Implementa esto como endpoint FastAPI con Pydantic models, dependency injection y documentación automática.",
				},
			}

			return {
				provider = "gemini",
				providers = {
					gemini = {
						endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
						model = "gemini-2.0-flash",
						api_key_name = "GEMINI_API_KEY",
						timeout = 30000,
						temperature = 0.1,
						max_tokens = 8192,
						system_prompt = system_prompt,
					},
				},
				web_search_engine = {
					provider = "google",
					search_options = {
						site_priority = search_priorities[current_profile] or search_priorities.elixir,
					},
				},
				behaviour = {
					auto_suggestions = true,
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = false,
					support_paste_from_clipboard = true,
				},
				windows = {
					position = "right",
					width = 40,
					sidebar_header = {
						enabled = true,
						align = "center",
						rounded = true,
					},
					input = {
						prefix = "> ",
						height = 10,
					},
					edit = {
						border = "rounded",
						start_insert = true,
					},
					ask = {
						floating = false,
						start_insert = true,
						border = "rounded",
					},
				},
				mappings = {
					diff = {
						ours = "co",
						theirs = "ct",
						all_theirs = "ca",
						both = "cb",
						cursor = "cc",
						next = "]x",
						prev = "[x",
					},
				},
				tools = {
					enabled = true,
				},
				selector = { provider = "telescope" },
				history = {
					storage_path = vim.fn.stdpath("state") .. "/avante",
					max_items = 100,
				},
				templates = templates[current_profile] or templates.elixir,
			}
		end,
		config = function(_, opts)
			require("avante").setup(opts)

			local current_profile = vim.g.nvim_profile or vim.env.nvim_profile or "elixir"

			local file_patterns = {
				elixir = { "elixir", "eelixir", "heex" },
				php = { "php", "blade", "twig" },
				python = { "python", "django" },
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.list_extend(file_patterns[current_profile] or file_patterns.elixir, { "Avante" }),
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
				end,
			})

			vim.api.nvim_create_user_command("AvanteReloadProfile", function()
				package.loaded["avante"] = nil
				package.loaded["avante.config"] = nil

				local new_opts = opts()

				require("avante").setup(new_opts)

				local profile = vim.g.nvim_profile or vim.env.nvim_profile or "elixir"
				print("✅ Avante recargado con perfil: " .. profile)
			end, {})
		end,
	},

	-- Explorador de directorios
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				filters = {
					dotfiles = false,
					custom = {},
				},
				git = { ignore = false },
				view = { width = 50, side = "left" },
				renderer = {
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
						},
					},
				},
				actions = {
					open_file = { quit_on_open = true },
				},
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
			})
		end,
	},

	-- Bufferline
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					separator_style = "slam",
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = false,
					show_close_icon = false,
					always_show_bufferline = true,
					enforce_regular_tabs = false,
				},
			})
		end,
	},

	-- Alpha (Dashboard)
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
				"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
				"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
				"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
				"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
				"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
			}

			dashboard.section.buttons.val = {
				dashboard.button("e", "📄  Nuevo archivo", ":ene <BAR> startinsert<CR>"),
				dashboard.button("f", "🔍  Buscar archivo", ":Telescope find_files<CR>"),
				dashboard.button("r", "📋  Archivos recientes", ":Telescope oldfiles<CR>"),
				dashboard.button("p", "📂  Proyectos", ":Telescope projects<CR>"),
				dashboard.button("s", "⚙️  Configuración", ":e $MYVIMRC<CR>"),
				dashboard.button("u", "🔄  Actualizar plugins", ":Lazy sync<CR>"),
				dashboard.button("q", "🚪  Salir", ":qa<CR>"),
			}

			dashboard.section.footer.val = "José"
			alpha.setup(dashboard.opts)
		end,
	},

	-- Terminal flotante
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm" },
		opts = {
			direction = "float",
			float_opts = { border = "rounded" },
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)
		end,
	},

	-- Proyectos
	{
		"ahmedkhalf/project.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("project_nvim").setup({
				detection_methods = { "pattern" },
				patterns = { ".git", "Makefile", "package.json", "mix.exs" },
				manual_mode = false,
				show_hidden = true,
				silent_chdir = false,
			})
			require("telescope").load_extension("projects")
		end,
	},

	-- Notificaciones mejoradas
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		config = function()
			vim.g.mkdp_auto_start = 1
		end,
	},

	-- Git Signs
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				numhl = true,
				current_line_blame = true,
				sign_priority = 6,
			})
		end,
	},

	-- Lualine (barra de estado)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "gruvbox_dark",
					component_separators = "|",
					section_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						"%f",
						{
							function()
								local filename = vim.fn.expand("%:t")
								local filetype = vim.bo.filetype
								if filetype == "typescriptreact" or filetype == "javascriptreact" then
									local name = filename:match("(.+)%..+$")
									if name then
										return "React: " .. name
									end
									return ""
								end
								return ""
							end,
							cond = function()
								local filetype = vim.bo.filetype
								return filetype == "typescriptreact" or filetype == "javascriptreact"
							end,
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- REST client
	{
		"rest-nvim/rest.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("rest-nvim").setup({
				result_split_horizontal = false,
				skip_ssl_verification = false,
				encode_url = true,
				highlight = { enabled = true },
			})
		end,
	},

	-- Git
	{ "tpope/vim-fugitive" },
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("diffview").setup({
				use_icons = true,
				enhanced_diff_hl = true,
				key_bindings = {
					view = {
						["<tab>"] = function(bufnr)
							require("diffview.actions").select_next_entry()
						end,
						["<s-tab>"] = function(bufnr)
							require("diffview.actions").select_prev_entry()
						end,
					},
					file_panel = {
						["j"] = function()
							require("diffview.actions").next_entry()
						end,
						["k"] = function()
							require("diffview.actions").prev_entry()
						end,
					},
				},
			})
		end,
	},

	-- Frontend Development Plugins
	{
		"windwp/nvim-ts-autotag",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				filetypes = { "css", "scss", "html", "javascript", "typescript", "jsx", "tsx", "vue" },
				user_default_options = {
					RGB = true,
					RRGGBB = true,
					names = true,
					RRGGBBAA = true,
					rgb_fn = true,
					hsl_fn = true,
					mode = "background",
				},
			})
		end,
	},

	{
		"turbio/bracey.vim",
		build = "npm install --prefix server",
		config = function()
			vim.g.bracey_auto_start_browser = 1
			vim.g.bracey_refresh_on_save = 1
		end,
	},

	{ "dsznajder/vscode-react-javascript-snippets", build = "yarn install --frozen-lockfile && yarn compile" },
	{ "jparise/vim-graphql" },
	{ "styled-components/vim-styled-components" },

	{
		"mattn/emmet-vim",
		config = function()
			vim.g.user_emmet_settings = {
				javascript = { extends = "jsx" },
				typescript = { extends = "tsx" },
			}
			vim.g.user_emmet_install_global = 0
			vim.cmd([[
                autocmd FileType html,css,javascript,javascriptreact,typescript,typescriptreact EmmetInstall
            ]])
		end,
	},

	{
		"vim-test/vim-test",
		config = function()
			vim.g["test#javascript#jest#executable"] = "npm test --"
			vim.g["test#strategy"] = "neovim"
		end,
	},

	{
		"vuki656/package-info.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("package-info").setup()
		end,
	},

	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},

	{
		"othree/csscomplete.vim",
		config = function()
			vim.cmd("autocmd FileType css,scss,less,html setlocal omnifunc=csscomplete#CompleteCSS")
		end,
	},

	{ "tpope/vim-projectionist", lazy = false },
}, {
	rocks = { hererocks = true },
})
