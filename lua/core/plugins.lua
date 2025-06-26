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
				php = { "php-cs-fixer" },
				elixir = { "mix_format" },
				sql = { "sql_formatter" },
				heex = { "mix_format" },
				exs = { "mix_format" },
				ex = { "mix_format" },
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
		lazy = false,
		version = false,
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"hrsh7th/nvim-cmp",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		opts = {
			provider = "gemini",
			auto_suggestions_provider = "gemini",

			providers = {
				gemini = {
					-- endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
					model = "gemini-2.5-flash",
					api_key_name = "GEMINI_API_KEY",
					extra_request_body = {
						temperature = 0,
						max_tokens = 8192,
					},
					timeout = 30000,
				},
			},

			behaviour = {
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = false,
				minimize_diff = true,
				enable_token_counting = true,
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
				suggestion = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				cancel = {
					normal = { "<C-c>", "<Esc>", "q" },
					insert = { "<C-c>" },
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					retry_user_request = "r",
					edit_user_request = "e",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
					remove_file = "d",
					add_file = "@",
					close = { "<Esc>", "q" },
					close_from_input = nil,
				},
			},

			windows = {
				position = "right",
				wrap = true,
				width = 30,
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
				input = {
					prefix = "> ",
					height = 8,
				},
				edit = {
					border = "rounded",
					start_insert = true,
				},
				ask = {
					floating = false,
					start_insert = true,
					border = "rounded",
					focus_on_apply = "ours",
				},
			},

			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},

			diff = {
				autojump = true,
				list_opener = "copen",
				override_timeoutlen = 500,
			},

			hints = { enabled = true },

			suggestion = {
				debounce = 600,
				throttle = 600,
			},

			system_prompt = [[
            Eres un asistente de programación experto que SIEMPRE responde en español.

## Especialidades principales:
            - **Elixir/Phoenix**: OTP, GenServer, LiveView, Ecto, pattern matching, procesos concurrentes, supervisión
            - **React/TypeScript**: Hooks, componentes funcionales, gestión de estado, optimización de rendimiento, type safety
            - **PHP/Laravel**: Eloquent, middleware, validation, dependency injection, Blade templates, Service Container

## Principios de trabajo:
            - Código limpio, eficiente y mantenible
            - Aplicar mejores prácticas y patrones de diseño modernos
            - Explicaciones técnicas claras y detalladas
            - Comentarios en español, código en inglés
            - Usar terminología técnica apropiada en español
            - Considerar escalabilidad y performance

## Estilo de respuesta:
            - Respuestas concisas pero completas
            - Incluir ejemplos prácticos cuando sea relevante
            - Enfoque en soluciones productivas y escalables
            - Considerar el contexto del proyecto actual
            - Sugerir optimizaciones y mejores prácticas
            - Proporcionar alternativas cuando sea apropiado

            Mantén las respuestas enfocadas en la tarea de desarrollo y proporciona soluciones prácticas que mejoren la calidad del código.
]],
		},
		config = function(_, opts)
			require("avante").setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "Avante",
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.breakindent = true
				end,
			})

			vim.api.nvim_create_user_command("AvanteAnalyze", function()
				require("avante.api").ask({
					question = "Analiza este código y sugiere mejoras de rendimiento, legibilidad y mejores prácticas. Incluye sugerencias específicas para optimización. Responde en español.",
				})
			end, { desc = "Avante: Análisis completo del código" })

			vim.api.nvim_create_user_command("AvanteElixir", function()
				require("avante.api").ask({
					question = "Analiza este código Elixir siguiendo principios OTP y mejores prácticas. Considera el uso de GenServers, supervisores, pattern matching y procesos concurrentes. Evalúa la gestión de errores y la tolerancia a fallos. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para Elixir" })

			vim.api.nvim_create_user_command("AvanteElixirTest", function()
				require("avante.api").ask({
					question = "Genera tests ExUnit exhaustivos para este código Elixir. Incluye casos edge, doctest, tests de integración y tests de concurrencia cuando sea apropiado. Asegúrate de testear fallos y recuperación. Responde en español.",
				})
			end, { desc = "Avante: Generar tests para Elixir" })

			vim.api.nvim_create_user_command("AvanteReact", function()
				require("avante.api").ask({
					question = "Revisa este componente React/TypeScript para optimización de rendimiento, type safety y mejores prácticas. Considera hooks, memoización, patrones de composición y accessibility. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para React" })

			vim.api.nvim_create_user_command("AvantePHP", function()
				require("avante.api").ask({
					question = "Analiza este código PHP/Laravel siguiendo principios SOLID y convenciones de Laravel. Considera el uso de Service Providers, Middleware, Eloquent relationships y optimización de queries. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para PHP" })

			vim.api.nvim_create_user_command("AvanteRefactor", function()
				require("avante.api").ask({
					question = "Refactoriza este código para mejorar su legibilidad, mantenibilidad y rendimiento. Aplica patrones de diseño apropiados y elimina code smells. Explica los cambios realizados. Responde en español.",
				})
			end, { desc = "Avante: Refactorización avanzada" })

			vim.api.nvim_create_user_command("AvanteDebug", function()
				local diagnostics = vim.diagnostic.get(0)
				local diagnostic_text = ""

				if #diagnostics > 0 then
					diagnostic_text = "\n\nDiagnósticos actuales:\n"
					for _, diag in ipairs(diagnostics) do
						diagnostic_text = diagnostic_text .. "- " .. diag.message .. "\n"
					end
				end

				require("avante.api").ask({
					question = "Ayúdame a debuggear este código. Identifica posibles problemas, explica las causas y proporciona soluciones paso a paso. Incluye estrategias de debugging específicas para el lenguaje. Responde en español."
						.. diagnostic_text,
				})
			end, { desc = "Avante: Modo debugging con diagnósticos" })

			vim.api.nvim_create_user_command("AvanteDoc", function()
				require("avante.api").ask({
					question = "Genera documentación completa para este código incluyendo descripción, parámetros, valores de retorno, ejemplos de uso y posibles excepciones. Usa el formato de documentación apropiado para el lenguaje. Responde en español.",
				})
			end, { desc = "Avante: Generar documentación" })

			vim.api.nvim_create_user_command("AvanteOptimize", function()
				require("avante.api").ask({
					question = "Optimiza este código para mejorar el rendimiento. Identifica cuellos de botella, sugiere mejoras algorítmicas y técnicas de optimización específicas del lenguaje. Explica el impacto de cada optimización. Responde en español.",
				})
			end, { desc = "Avante: Optimización de performance" })

			vim.api.nvim_create_user_command("AvanteSecurity", function()
				require("avante.api").ask({
					question = "Revisa este código desde una perspectiva de seguridad. Identifica vulnerabilidades potenciales, problemas de validación de entrada, gestión de errores insegura y sugiere mejoras de seguridad. Responde en español.",
				})
			end, { desc = "Avante: Análisis de seguridad" })

			-- local map = vim.api.nvim_set_keymap
			-- local opts_map = { noremap = true, silent = true }

			-- Atajos principales de Avante
			-- map("n", "<leader>aa", ":AvanteAsk ", { noremap = true, desc = "Avante: Ask AI" })
			-- map("v", "<leader>aa", ":AvanteAsk ", { noremap = true, desc = "Avante: Ask AI with selection" })
			-- map("n", "<leader>ac", ":AvanteChat<CR>", opts_map)
			-- map("n", "<leader>at", ":AvanteToggle<CR>", opts_map)
			-- map("n", "<leader>ar", ":AvanteRefresh<CR>", opts_map)
			-- map("n", "<leader>af", ":AvanteFocus<CR>", opts_map)
			-- map("n", "<leader>ae", ":AvanteEdit<CR>", opts_map)
			-- map("v", "<leader>ae", ":AvanteEdit<CR>", opts_map)
			--
			-- -- Atajos para comandos específicos
			-- map("n", "<leader>aan", ":AvanteAnalyze<CR>", opts_map) -- Analyze
			-- map("n", "<leader>aer", ":AvanteElixir<CR>", opts_map) -- Elixir
			-- map("n", "<leader>aet", ":AvanteElixirTest<CR>", opts_map) -- Elixir Test
			-- map("n", "<leader>arc", ":AvanteReact<CR>", opts_map) -- React
			-- map("n", "<leader>aph", ":AvantePHP<CR>", opts_map) -- PHP
			-- map("n", "<leader>arf", ":AvanteRefactor<CR>", opts_map) -- Refactor
			-- map("n", "<leader>adb", ":AvanteDebug<CR>", opts_map) -- Debug
			-- map("n", "<leader>adc", ":AvanteDoc<CR>", opts_map) -- Documentation
			-- map("n", "<leader>aop", ":AvanteOptimize<CR>", opts_map) -- Optimize
			-- map("n", "<leader>asc", ":AvanteSecurity<CR>", opts_map) -- Security

			-- Notificación de configuración exitosa
			-- vim.notify("✅ Avante.nvim configurado correctamente con Google Gemini", vim.log.levels.INFO)
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
