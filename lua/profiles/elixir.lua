-- lua/profiles/elixir.lua - Perfil Elixir con autocompletado mejorado
print("⚗️ Cargando perfil Elixir...")
vim.g.mapleader = " "

require("core.plugins")
local lsp_config = require("core.lsp")
local lspconfig = require("lspconfig")

-- Función para encontrar ElixirLS
local function find_elixir_ls()
	local paths = {
		vim.fn.expand("~/.local/bin/elixir-ls"),
		vim.fn.stdpath("data") .. "/mason/bin/elixir-ls",
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

	-- IMPORTANTE: Usar las capacidades del core LSP
	lspconfig.elixirls.setup({
		cmd = { elixir_ls_cmd },
		capabilities = lsp_config.capabilities, -- Usar capabilities con nvim-cmp
		on_attach = function(client, bufnr)
			-- Usar on_attach del core
			lsp_config.on_attach(client, bufnr)

			-- Configuración adicional específica de Elixir
			vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
			client.server_capabilities.documentFormattingProvider = true

			-- Configurar autocompletado específico para Elixir
			vim.api.nvim_buf_create_autocmd("TextChangedI", {
				buffer = bufnr,
				callback = function()
					-- Forzar actualización del autocompletado
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					local line = vim.api.nvim_get_current_line()
					local before_cursor = line:sub(1, col)

					-- Si estamos escribiendo una palabra que empieza con 'def'
					if before_cursor:match("def[a-z]*$") then
						-- Trigger autocompletado
						vim.schedule(function()
							require("cmp").complete()
						end)
					end
				end,
			})
		end,
		settings = {
			elixirLS = {
				dialyzerEnabled = false,
				fetchDeps = false,
				suggestSpecs = true,
				signatureAfterComplete = true,
				mixEnv = "dev",
				enableTestLenses = false,
			},
		},
		root_dir = lspconfig.util.root_pattern("mix.exs", ".git"),
		flags = {
			debounce_text_changes = 150,
			allow_incremental_sync = true,
		},
	})
else
	print("❌ ElixirLS no encontrado")
	print("💡 Instala con: :MasonInstall elixir-ls")
end

-- Configuración básica sin conflictos
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "elixir", "eelixir", "heex" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.expandtab = true

		-- Configurar timeout para mejor respuesta del autocompletado
		vim.opt_local.updatetime = 300
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
			print(
				"- Capacidades de autocompletado: "
					.. (client.server_capabilities.completionProvider and "✅ Sí" or "❌ No")
			)
		end
	else
		print("- LSP: ❌ No hay clientes activos")
	end

	-- Verificar nvim-cmp
	local has_cmp = pcall(require, "cmp")
	print("- nvim-cmp: " .. (has_cmp and "✅ Instalado" or "❌ No instalado"))
end, {})

print("✅ Perfil Elixir cargado con autocompletado")
