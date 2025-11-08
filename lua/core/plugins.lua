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
	-- Import plugins from lua/plugins/ directory
	{ import = "plugins" },

	-- Mason: Must be loaded BEFORE lspconfig
	{
		"williamboman/mason.nvim",
		priority = 100,
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					}
				}
			})
		end,
	},

	-- Mason-LSPConfig bridge: Automatically installs and enables LSPs
	{
		"williamboman/mason-lspconfig.nvim",
		priority = 90,
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			-- Lista de SOLO servidores LSP (NO formateadores)
			ensure_installed = {
				"lua_ls",
				"elixirls",
				"intelephense",
				"ts_ls",
				"pyright",
				"jdtls",
				"html",
				"cssls",
				"jsonls",
				"yamlls",
				"bashls",
			},
		},
	},

	-- Mason Tool Installer: Para formateadores y linters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Formatters
				"stylua",      -- Lua formatter
				"prettier",    -- JS/TS/HTML/CSS formatter
				-- Note: php-cs-fixer needs to be installed separately via Composer
			},
			auto_update = false,
			run_on_start = true,
		},
	},

	-- LSPConfig: Loaded AFTER Mason
	{
		"neovim/nvim-lspconfig",
		priority = 80,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Now it's safe to require lspconfig because Mason loaded it
			-- The actual LSP configuration is in core/lsp.lua
			-- This just ensures lspconfig is available when core/lsp.lua loads
			require("core.lsp")
		end,
	},

	-- Motor de autocompletado (INDEPENDIENTE, no en dependencias)
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Fuentes de autocompletado
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",

			-- Motor de snippets
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
				dependencies = {
					"rafamadriz/friendly-snippets",
				},
			},

			-- -- Copilot
			-- {
			-- 	"zbirenbaum/copilot-cmp",
			-- 	config = function()
			-- 		require("copilot_cmp").setup()
			-- 	end,
			-- 	dependencies = {
			-- 		"zbirenbaum/copilot.lua",
			-- 		cmd = "Copilot",
			-- 		config = function()
			-- 			require("copilot").setup({
			-- 				suggestion = { enabled = false },
			-- 				panel = { enabled = false },
			-- 			})
			-- 		end,
			-- 	},
			-- },

			-- Íconos para el menú
			"onsails/lspkind.nvim",
		},
	},

	-- Snippets específicos para Elixir
	{
		"florinpatrascu/vscode-elixir-snippets",
		event = { "BufReadPre *.ex", "BufReadPre *.exs", "BufReadPre *.heex" },
	},

	-- Schema store para JSON LSP
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
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
					file_ignore_patterns = { "node_modules", ".git", "dist", "vendor", "_build", "deps", "venv", "__pycache__", "target", "build", ".gradle", "bin", "storage", "bootstrap/cache", "cache", "bower_components", ".yarn", ".next", "public/build" },
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
				php = { "php-cs-fixer" },
				elixir = { "mix" },
				heex = { "mix" },
				eex = { "mix" },
				exs = { "mix" },
			},
			formatters = {
				mix = {
					command = "mix",
					args = { "format", "-" },
					stdin = true,
				},
			},
			format_on_save = function(bufnr)
				-- Desactivar formateo automático si el LSP ya lo está haciendo
				-- para evitar conflictos (aunque ya lo desactivamos en lsp.lua)
				return {
					timeout_ms = 1000,
					lsp_fallback = true,
				}
			end,
		},
		config = function(_, opts)
			require("conform").setup(opts)

			-- Crear comando :Format para compatibilidad
			vim.api.nvim_create_user_command("Format", function(args)
				local range = nil
				if args.count ~= -1 then
					local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
					range = {
						start = { args.line1, 0 },
						["end"] = { args.line2, end_line:len() },
					}
				end
				require("conform").format({ async = true, lsp_fallback = true, range = range })
			end, { range = true })

			-- Keymaps para formatear
			vim.keymap.set({ "n", "v" }, "<leader>f", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "Format buffer" })
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

	-- Tema Monokai (configuración movida a theme.lua)
	{
		"tanvirtin/monokai.nvim",
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
					separator_style = "slant",
					diagnostics = "nvim_lsp",
					diagnostics_update_in_insert = false,
					diagnostics_indicator = function(count, level, diagnostics_dict, context)
						local icon = level:match("error") and " " or " "
						return " " .. icon .. count
					end,
					show_buffer_close_icons = true,
					show_close_icon = true,
					always_show_bufferline = true,
					enforce_regular_tabs = false,
					show_buffer_icons = true,
					show_tab_indicators = true,
					persist_buffer_sort = true,
					sort_by = "insert_after_current",
					custom_filter = function(buf_number, buf_numbers)
						local filetype = vim.bo[buf_number].filetype
						if filetype == "qf" or filetype == "help" or filetype == "fugitive" then
							return false
						end
						return true
					end,
					offsets = {
						{
							filetype = "NvimTree",
							text = "📁 Explorador",
							text_align = "center",
							separator = true,
						},
						{
							filetype = "neo-tree",
							text = "📁 Neo Tree",
							text_align = "center",
							separator = true,
						},
					},
					groups = {
						items = {
							{
								name = "Tests",
								highlight = { underline = true, sp = "blue" },
								priority = 2,
								icon = "",
								matcher = function(buf)
									return buf.name:match("%_test") or buf.name:match("%.test%.")
								end,
							},
							{
								name = "Docs",
								highlight = { underline = true, sp = "green" },
								priority = 1,
								icon = "",
								matcher = function(buf)
									return buf.name:match("%.md") or buf.name:match("README")
								end,
							},
						},
					},
				},
				highlights = {
					buffer_selected = {
						bold = true,
						italic = false,
					},
					diagnostic_selected = {
						bold = true,
					},
					error_selected = {
						fg = "#e06c75",
						bold = true,
					},
					warning_selected = {
						fg = "#e5c07b",
						bold = true,
					},
				},
			})
		end,
	},

	-- Alpha (Dashboard)
	{
		"goolord/alpha-nvim",
		enabled = false,
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
					theme = "auto", -- Hereda el tema activo automáticamente
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

	-- REST client con Google Drive
	{
		"rest-nvim/rest.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Configuración básica de rest.nvim
			require("rest-nvim").setup({
				result_split_horizontal = false,
				result_split_in_place = false,
				skip_ssl_verification = false,
				encode_url = true,
				highlight = {
					enabled = true,
					timeout = 150,
				},
				result = {
					show_http_info = true,
					show_curl_command = false,
				},
			})

			-- Variables globales para rutas de Google Drive
			local GDRIVE_API_PATH = vim.fn.expand("~/Google Drive/API-Collections")
			local CURRENT_PROJECT = ""

			-- Función para crear la estructura de directorios si no existe
			local function ensure_gdrive_structure()
				local dirs = {
					GDRIVE_API_PATH,
					GDRIVE_API_PATH .. "/templates",
					GDRIVE_API_PATH .. "/shared",
				}

				for _, dir in ipairs(dirs) do
					if vim.fn.isdirectory(dir) == 0 then
						vim.fn.mkdir(dir, "p")
					end
				end
			end

			-- Función para listar proyectos disponibles
			local function list_projects()
				local projects = {}
				local handle = io.popen(
					'find "'
						.. GDRIVE_API_PATH
						.. '" -maxdepth 1 -type d -not -path "*/templates" -not -path "*/shared" -not -path "'
						.. GDRIVE_API_PATH
						.. '"'
				)

				if handle then
					for line in handle:lines() do
						local project_name = line:match("([^/]+)$")
						if project_name then
							table.insert(projects, project_name)
						end
					end
					handle:close()
				end

				return projects
			end

			-- Función para crear nuevo proyecto
			local function create_new_project()
				vim.ui.input({
					prompt = "Nombre del nuevo proyecto: ",
				}, function(project_name)
					if project_name and project_name ~= "" then
						local project_path = GDRIVE_API_PATH .. "/" .. project_name
						vim.fn.mkdir(project_path, "p")

						-- Crear template inicial
						local template_content = [[### Ejemplo de petición HTTP
# @base_url = https://api.ejemplo.com
# @token = Bearer tu_token_aqui

GET {{base_url}}/users
Authorization: {{token}}
Content-Type: application/json

###

POST {{base_url}}/users
Authorization: {{token}}
Content-Type: application/json

{
  "name": "Usuario Ejemplo",
  "email": "usuario@ejemplo.com"
}
]]

						local file_path = project_path .. "/example.rest"
						local file = io.open(file_path, "w")
						if file then
							file:write(template_content)
							file:close()
							vim.cmd("edit " .. file_path)
							print("Proyecto '" .. project_name .. "' creado exitosamente")
						end
					end
				end)
			end

			-- Función para abrir proyecto existente
			local function open_project()
				local projects = list_projects()

				if #projects == 0 then
					print("No hay proyectos disponibles. Crea uno nuevo primero.")
					return
				end

				vim.ui.select(projects, {
					prompt = "Selecciona un proyecto:",
				}, function(choice)
					if choice then
						CURRENT_PROJECT = choice
						local project_path = GDRIVE_API_PATH .. "/" .. choice
						vim.cmd("cd " .. project_path)
						vim.cmd("Explore " .. project_path)
						print("Proyecto '" .. choice .. "' abierto")
					end
				end)
			end

			-- Función para crear nuevo archivo .rest en el proyecto actual
			local function new_rest_file()
				if CURRENT_PROJECT == "" then
					print("Primero selecciona un proyecto")
					return
				end

				vim.ui.input({
					prompt = "Nombre del archivo .rest: ",
				}, function(filename)
					if filename and filename ~= "" then
						if not filename:match("%.rest$") then
							filename = filename .. ".rest"
						end

						local file_path = GDRIVE_API_PATH .. "/" .. CURRENT_PROJECT .. "/" .. filename
						vim.cmd("edit " .. file_path)
					end
				end)
			end

			-- Función para listar archivos .rest del proyecto actual
			local function list_rest_files()
				if CURRENT_PROJECT == "" then
					print("Primero selecciona un proyecto")
					return
				end

				local project_path = GDRIVE_API_PATH .. "/" .. CURRENT_PROJECT
				local files = {}

				local handle = io.popen('find "' .. project_path .. '" -name "*.rest" -type f')
				if handle then
					for line in handle:lines() do
						local filename = line:match("([^/]+)$")
						if filename then
							table.insert(files, {
								name = filename,
								path = line,
							})
						end
					end
					handle:close()
				end

				if #files == 0 then
					print("No hay archivos .rest en el proyecto actual")
					return
				end

				local file_names = {}
				for _, file in ipairs(files) do
					table.insert(file_names, file.name)
				end

				vim.ui.select(file_names, {
					prompt = "Selecciona archivo .rest:",
				}, function(choice)
					if choice then
						for _, file in ipairs(files) do
							if file.name == choice then
								vim.cmd("edit " .. file.path)
								break
							end
						end
					end
				end)
			end

			-- Exponer funciones globalmente para usar en keymaps
			_G.rest_gdrive = {
				open_project = open_project,
				create_new_project = create_new_project,
				new_rest_file = new_rest_file,
				list_rest_files = list_rest_files,
				api_home = function()
					vim.cmd("cd " .. GDRIVE_API_PATH)
					vim.cmd("Explore " .. GDRIVE_API_PATH)
				end,
				api_info = function()
					print("Directorio APIs: " .. GDRIVE_API_PATH)
					print("Proyecto actual: " .. (CURRENT_PROJECT ~= "" and CURRENT_PROJECT or "Ninguno"))
					print("Proyectos disponibles: " .. #list_projects())
				end,
			}

			-- Inicializar estructura
			ensure_gdrive_structure()

			-- Comandos para acceso rápido
			vim.api.nvim_create_user_command(
				"ApiHome",
				_G.rest_gdrive.api_home,
				{ desc = "Rest: Abrir directorio raíz de APIs en Google Drive" }
			)
			vim.api.nvim_create_user_command(
				"ApiInfo",
				_G.rest_gdrive.api_info,
				{ desc = "Rest: Mostrar información del proyecto de API actual" }
			)
			vim.api.nvim_create_user_command(
				"RestNewProject",
				_G.rest_gdrive.create_new_project,
				{ desc = "Rest: Crear nuevo proyecto de API en Google Drive" }
			)
			vim.api.nvim_create_user_command(
				"RestOpenProject",
				_G.rest_gdrive.open_project,
				{ desc = "Rest: Abrir un proyecto de API existente en Google Drive" }
			)
			vim.api.nvim_create_user_command(
				"RestNewFile",
				_G.rest_gdrive.new_rest_file,
				{ desc = "Rest: Crear nuevo archivo .rest en el proyecto actual" }
			)
			vim.api.nvim_create_user_command(
				"RestListFiles",
				_G.rest_gdrive.list_rest_files,
				{ desc = "Rest: Listar archivos .rest en el proyecto actual" }
			)
		end,
	},
}, {
	rocks = { hererocks = true },
})
