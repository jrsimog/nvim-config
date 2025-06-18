-- lua/profiles/elixir.lua - Usar Mason de forma controlada
print("⚗️ Cargando perfil Elixir...")

vim.g.mapleader = " "
require("core.plugins")
require("core.lsp")

local lspconfig = require("lspconfig")

-- Función para encontrar ElixirLS (preferir manual, fallback a Mason)
local function find_elixir_ls()
	local paths = {
		-- Preferir manual primero
		vim.fn.expand("~/.local/bin/elixir-ls"),
		-- Fallback a Mason si existe
		vim.fn.stdpath("data") .. "/mason/bin/elixir-ls",
		-- Sistema
		vim.fn.exepath("elixir-ls"),
	}

	for _, path in ipairs(paths) do
		if path ~= "" and vim.fn.executable(path) == 1 then
			return path
		end
	end

	return nil
end

local elixir_ls_cmd = find_elixir_ls()

if elixir_ls_cmd then
	local source = elixir_ls_cmd:match("mason") and "Mason" or "Manual"
	print("✅ ElixirLS encontrado (" .. source .. "): " .. elixir_ls_cmd)

	lspconfig.elixirls.setup({
		cmd = { elixir_ls_cmd },
		settings = {
			elixirLS = {
				-- Configuración conservadora
				dialyzerEnabled = false,
				fetchDeps = false,
				suggestSpecs = false,
				signatureAfterComplete = false,
				mixEnv = "dev",
				-- Configuraciones adicionales para Mason
				enableTestLenses = false,
				envVariables = {},
			},
		},
		-- on_attach sin autocomandos problemáticos
		on_attach = function(client, bufnr)
			vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
			client.server_capabilities.documentFormattingProvider = false

			print("⚗️ ElixirLS (" .. source .. ") conectado al buffer " .. bufnr)
		end,
		root_dir = lspconfig.util.root_pattern("mix.exs", ".git"),
		flags = {
			debounce_text_changes = 300,
			allow_incremental_sync = true,
		},
		-- Manejo de errores
		on_exit = function(code, signal)
			if code ~= 0 then
				vim.schedule(function()
					vim.notify("⚠️ ElixirLS terminó con código: " .. code, vim.log.levels.WARN)
				end)
			end
		end,
	})
else
	print("❌ ElixirLS no encontrado")
	print("💡 Instala con: :MasonInstall elixir-ls")

	vim.schedule(function()
		vim.notify("ElixirLS no encontrado. Usa :MasonInstall elixir-ls", vim.log.levels.WARN)
	end)
end

-- Configuración básica sin conflictos
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "elixir", "eelixir", "heex" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.expandtab = true
	end,
})

-- Comandos útiles
vim.api.nvim_create_user_command("ElixirStatus", function()
	print("🔍 Estado de ElixirLS:")
	print("- Comando: " .. (elixir_ls_cmd or "❌ No encontrado"))
	print("- Tipo: " .. (elixir_ls_cmd and (elixir_ls_cmd:match("mason") and "Mason" or "Manual") or "N/A"))

	local clients = vim.lsp.get_active_clients({ name = "elixirls" })
	if #clients > 0 then
		for _, client in ipairs(clients) do
			print("- Cliente " .. client.id .. ": " .. (client.is_stopped() and "❌ Detenido" or "✅ Activo"))
		end
	else
		print("- LSP: ❌ No hay clientes activos")
	end
end, {})

vim.api.nvim_create_user_command("ElixirInstallMason", function()
	vim.cmd("MasonInstall elixir-ls")
	vim.notify("🔄 Instalando ElixirLS con Mason...", vim.log.levels.INFO)
end, {})

-- Keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<leader>mes", ":ElixirStatus<CR>", opts)
map("n", "<leader>mei", ":ElixirInstallMason<CR>", opts)

print("✅ Perfil Elixir cargado")
