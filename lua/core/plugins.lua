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
		version = false,
		build = "make BUILD_FROM_SOURCE=true",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"github/copilot.vim",
			"hrsh7th/nvim-cmp",
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
		opts = {
			provider = "gemini",
			auto_suggestions_provider = "copilot",

			providers = {
				gemini = {
					model = "gemini-2.5-pro",
					api_key_name = "GEMINI_API_KEY",
					timeout = 30000,
					temperature = 0,
					max_tokens = 8192,
				},
			},

			web_search_engine = {
				provider = "google",
				providers = {
					google = {
						api_key_name = "GOOGLE_SEARCH_API_KEY",
						engine_id_name = "GOOGLE_SEARCH_ENGINE_ID",
						extra_request_body = {},
						format_response_body = function(body)
							if body.items ~= nil then
								local jsn = vim.iter(body.items)
									:map(function(result)
										return {
											title = result.title,
											link = result.link,
											snippet = result.snippet,
										}
									end)
									:take(10)
									:totable()
								return vim.json.encode(jsn), nil
							end
							return "", nil
						end,
					},
				},
			},

			system_prompt = [[
            Eres un asistente de programación experto que SIEMPRE responde en español.

## Especialidades:
            - **Elixir/Phoenix**: OTP, GenServer, LiveView, Ecto, pattern matching
            - **React/TypeScript**: Hooks, componentes funcionales, type safety, performance
            - **PHP/Laravel**: Eloquent, middleware, validation, dependency injection

## Principios:
            - Código limpio, eficiente y mantenible
            - Mejores prácticas y patrones de diseño
            - Explicaciones técnicas claras
            - Comentarios en español, código en inglés
            - Usar terminología técnica apropiada

## Estilo de respuesta:
            - Conciso pero completo
            - Ejemplos prácticos
            - Enfoque en soluciones productivas
            - Considerar el contexto del proyecto actual

            Mantén las respuestas enfocadas en la tarea de desarrollo.
            ]],

			-- Templates personalizadas
			templates = {
				ask = [[
            {{{input}}}

            Por favor responde en español con explicaciones técnicas detalladas.
            ]],
				edit = [[
            Modifica este código siguiendo mejores prácticas:

            {{{code_snippet}}}

            Instrucciones específicas: {{{input}}}

            Explica los cambios realizados en español.
            ]],
				suggest = [[
            Analiza este código y sugiere mejoras:

            {{{code_snippet}}}

            Contexto adicional: {{{input}}}

            Proporciona sugerencias específicas en español.
            ]],
			},

			behaviour = {
				auto_suggestions = false,
				auto_set_keymaps = false,
				auto_apply_diff_after_generation = false,
				minimize_diff = true,
				enable_token_counting = true,
			},

			windows = {
				position = "right",
				width = 35,
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
				input = {
					height = 8,
					border = "rounded",
				},
				edit = {
					border = "rounded",
				},
				ask = {
					floating = false,
					border = "rounded",
				},
			},

			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},

			suggestion = {
				debounce = 1000,
				throttle = 1000,
			},
		},
		config = function(_, opts)
			require("avante").setup(opts)

			local map = vim.keymap.set
			local opts_map = { noremap = true, silent = true }

			map("n", "<leader>aa", function()
				require("avante.api").ask()
			end, vim.tbl_extend("force", opts_map, { desc = "Avante: Ask" }))

			map("v", "<leader>aa", function()
				require("avante.api").ask()
			end, vim.tbl_extend("force", opts_map, { desc = "Avante: Ask with selection" }))

			map("n", "<leader>ae", function()
				require("avante.api").edit()
			end, vim.tbl_extend("force", opts_map, { desc = "Avante: Edit" }))

			map("v", "<leader>ae", function()
				require("avante.api").edit()
			end, vim.tbl_extend("force", opts_map, { desc = "Avante: Edit selection" }))

			map("n", "<leader>ar", function()
				require("avante.api").refresh()
			end, vim.tbl_extend("force", opts_map, { desc = "Avante: Refresh" }))

			map(
				"n",
				"<leader>at",
				"<cmd>AvanteToggle<CR>",
				vim.tbl_extend("force", opts_map, { desc = "Avante: Toggle" })
			)

			map(
				"n",
				"<leader>af",
				"<cmd>AvanteFocus<CR>",
				vim.tbl_extend("force", opts_map, { desc = "Avante: Focus" })
			)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "Avante",
				callback = function(args)
					local bufnr = args.buf

					map("n", "co", function()
						require("avante.diff").choose("ours")
					end, { buffer = bufnr, desc = "Choose ours" })

					map("n", "ct", function()
						require("avante.diff").choose("theirs")
					end, { buffer = bufnr, desc = "Choose theirs" })

					map("n", "ca", function()
						require("avante.diff").choose("all_theirs")
					end, { buffer = bufnr, desc = "Choose all theirs" })

					map("n", "cb", function()
						require("avante.diff").choose("both")
					end, { buffer = bufnr, desc = "Choose both" })

					map("n", "cc", function()
						require("avante.diff").choose("cursor")
					end, { buffer = bufnr, desc = "Choose cursor" })

					map("n", "]x", function()
						require("avante.diff").next()
					end, { buffer = bufnr, desc = "Next diff" })

					map("n", "[x", function()
						require("avante.diff").prev()
					end, { buffer = bufnr, desc = "Previous diff" })

					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
				end,
			})

			vim.api.nvim_create_user_command("AvanteElixir", function()
				require("avante.api").ask({
					question = "Analiza este código Elixir siguiendo principios OTP y mejores prácticas. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para Elixir" })

			vim.api.nvim_create_user_command("AvanteReact", function()
				require("avante.api").ask({
					question = "Revisa este componente React/TypeScript para performance, type safety y mejores prácticas. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para React" })

			vim.api.nvim_create_user_command("AvantePHP", function()
				require("avante.api").ask({
					question = "Analiza este código PHP/Laravel siguiendo principios SOLID y convenciones de Laravel. Responde en español.",
				})
			end, { desc = "Avante: Análisis específico para PHP" })

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
					question = "Ayúdame a debuggear este código. Explica posibles problemas y soluciones en español."
						.. diagnostic_text,
				})
			end, { desc = "Avante: Modo debugging con diagnósticos" })
			-- vim.notify("✅ Avante.nvim configurado correctamente", vim.log.levels.INFO)
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
