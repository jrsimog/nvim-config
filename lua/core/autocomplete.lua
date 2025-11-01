-- lua/core/autocomplete.lua - Configuración mejorada de autocompletado

-- Proteger contra carga sin plugins
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
	return
end

local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
	return
end

local lspkind_ok, lspkind = pcall(require, "lspkind")
if not lspkind_ok then
	return
end

-- Cargar snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Función helper para Tab
local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),

		-- Tab mejorado
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 1000 },
		{ name = "luasnip", priority = 750 },
		{ name = "nvim_lua", priority = 600 },
		{ name = "path", priority = 250 },
	}, {
		{ name = "buffer", priority = 500 },
	}),

	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			maxwidth = 50,
			ellipsis_char = "...",
			before = function(entry, vim_item)
				-- Mostrar origen de la sugerencia
				vim_item.menu = ({
					nvim_lsp = "[LSP]",
					luasnip = "[Snippet]",
					buffer = "[Buffer]",
					path = "[Path]",
					nvim_lua = "[Lua]",
				})[entry.source.name]
				return vim_item
			end,
		}),
	},

	experimental = {
		ghost_text = true,
	},

	performance = {
		max_view_entries = 20,
	},
})

-- Configuración para búsqueda
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Configuración para comandos
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

-- Configuración específica para Elixir
cmp.setup.filetype({ "elixir", "eelixir", "heex" }, {
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 1000 },
		{ name = "luasnip", priority = 750 },
		{ name = "path", priority = 250 },
	}, {
		{
			name = "buffer",
			priority = 500,
			option = {
				get_bufnrs = function()
					-- Solo buscar en buffers de Elixir
					local bufs = {}
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						local buftype = vim.api.nvim_buf_get_option(buf, "filetype")
						if buftype == "elixir" or buftype == "eelixir" then
							bufs[#bufs + 1] = buf
						end
					end
					return bufs
				end,
			},
		},
	}),
})

-- Configuración específica para archivos git
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" },
	}, {
		{ name = "buffer" },
	}),
})

-- Integración con autopairs si está instalado
local status_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
if status_ok then
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

-- Función para verificar el estado del autocompletado
_G.check_autocomplete = function()
	print("🔍 Estado del autocompletado:")
	print("- nvim-cmp: " .. (pcall(require, "cmp") and "✅ Cargado" or "❌ No encontrado"))
	print("- LuaSnip: " .. (pcall(require, "luasnip") and "✅ Cargado" or "❌ No encontrado"))
	print("- lspkind: " .. (pcall(require, "lspkind") and "✅ Cargado" or "❌ No encontrado"))

	local sources = {}
	for _, source in ipairs(cmp.get_config().sources) do
		table.insert(sources, source.name)
	end
	print("- Fuentes activas: " .. table.concat(sources, ", "))
end

-- Comando para debug
vim.api.nvim_create_user_command("CheckAutocomplete", "lua _G.check_autocomplete()", {})

-- print("✅ Autocompletado configurado con lspkind")
