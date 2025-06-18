-- lua/profiles/php.lua
-- 🐘 Cargando perfil PHP con Symfony y Laravel
print("🐘 Cargando perfil PHP con Symfony y Laravel")

vim.g.mapleader = " "

-- Cargar configuraciones base
require("core.plugins")
require("core.lsp") -- Carga LSP base (sin PHP ni Elixir)

-- Configurar Intelephense específicamente para este perfil
local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.intelephense.setup({
	capabilities = capabilities,
	settings = {
		intelephense = {
			files = {
				maxSize = 5000000,
				associations = { "*.php", "*.html", "*.css", "*.php", "*.php.html", "*.php.css" },
			},
			diagnostics = { enable = true },
			completion = {
				fullyQualifyGlobalConstantsAndFunctions = true,
				insertUseDeclaration = true,
				maxItems = 100,
			},
			trace = { server = "messages" },
		},
	},
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

		vim.api.nvim_buf_create_user_command(bufnr, "PhpImportClass", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.addMissingImports" },
				},
			})
		end, {})

		vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-CR>", ":PhpImportClass<CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(
			bufnr,
			"i",
			"<C-CR>",
			"<Esc>:PhpImportClass<CR>a",
			{ noremap = true, silent = true }
		)

		vim.api.nvim_create_autocmd("CompleteDone", {
			buffer = bufnr,
			callback = function()
				local completed_item = vim.v.completed_item
				if
					completed_item
					and completed_item.user_data
					and completed_item.user_data.lspitem
					and completed_item.user_data.lspitem.kind == 7
				then
					vim.defer_fn(function()
						vim.cmd("PhpImportClass")
					end, 100)
				end
			end,
		})

		print("✅ Intelephense conectado con importación automática para PHP")
	end,
})

-- Configuración específica de PHP
vim.g.laravel_cache = 1

-- Keymaps específicos de PHP (solo los que no están en keymaps.lua)
vim.api.nvim_set_keymap("n", "<leader>pl", ":Laravel<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ps", ":!symfony server:start<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pc", ":!symfony console<CR>", { noremap = true, silent = true })

-- Formateo automático con php-cs-fixer antes de guardar
vim.cmd([[autocmd BufWritePre *.php lua vim.lsp.buf.format()]])

-- Comandos útiles para PHP
vim.api.nvim_create_user_command("PhpIndexRefresh", function()
	vim.cmd("LspRestart intelephense")
	print("🔄 Reiniciando indexación de PHP...")
end, {})

vim.api.nvim_create_user_command("PhpImport", function()
	vim.lsp.buf.code_action({
		context = {
			only = { "source.addMissingImports" },
		},
	})
end, {})

-- Configuraciones adicionales específicas para PHP
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "php" },
	callback = function()
		-- Configurar indentación para archivos PHP
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true
	end,
})

print("✅ Perfil PHP cargado con soporte de importación automática")
