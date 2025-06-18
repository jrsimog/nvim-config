-- lua/core/lsp.lua - Configuración de LSP mejorada con diagnósticos
local lspconfig = require("lspconfig")

-- Configuración global de diagnósticos (aplicable a todos los perfiles)
vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		prefix = "●", -- Ícono para errores inline
		source = "always", -- Mostrar fuente del error
		format = function(diagnostic)
			-- Mostrar solo los primeros 50 caracteres del mensaje
			local message = diagnostic.message
			if #message > 50 then
				return string.sub(message, 1, 50) .. "..."
			end
			return message
		end,
	},
	float = {
		enabled = true,
		source = "always", -- Mostrar fuente en ventanas flotantes
		border = "rounded",
		header = "Diagnóstico",
		prefix = "● ",
		format = function(diagnostic)
			local code = diagnostic.code and string.format(" [%s]", diagnostic.code) or ""
			return string.format("%s%s", diagnostic.message, code)
		end,
	},
	signs = {
		enabled = true,
		priority = 8, -- Prioridad alta para que se vean sobre otros signos
	},
	underline = true,
	update_in_insert = false, -- No actualizar en modo inserción para mejor rendimiento
	severity_sort = true, -- Ordenar por severidad (errores primero)
})

-- Configurar signos de diagnóstico con íconos más llamativos
local signs = {
	Error = "󰅚 ",
	Warn = "󰀪 ",
	Hint = "󰌶 ",
	Info = " ",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configuración común para on_attach mejorada
local on_attach = function(client, bufnr)
	-- Habilitar completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Configurar hover automático para mostrar errores
	local group = vim.api.nvim_create_augroup("lsp_diagnostics_" .. bufnr, { clear = true })

	-- Mostrar diagnósticos automáticamente al mantener el cursor
	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		buffer = bufnr,
		callback = function()
			-- Solo mostrar si hay diagnósticos en la línea actual
			local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })
			if #diagnostics > 0 then
				vim.diagnostic.open_float(nil, {
					focus = false,
					scope = "cursor",
					close_events = { "CursorMoved", "InsertEnter" },
				})
			end
		end,
	})

	-- Configuraciones específicas por cliente
	if client.name == "elixirls" then
		print("⚗️ ElixirLS conectado - Diagnósticos habilitados para buffer " .. bufnr)
		-- Deshabilitar formato si usas mix format
		client.server_capabilities.documentFormattingProvider = false

		-- Configurar autocomandos específicos para Elixir
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			buffer = bufnr,
			pattern = "*.ex,*.exs",
			callback = function()
				-- Ejecutar mix compile después de guardar para obtener errores actualizados
				vim.fn.jobstart("mix compile", {
					on_exit = function(_, exit_code)
						if exit_code ~= 0 then
							vim.schedule(function()
								vim.notify("Mix compile falló - revisa los errores", vim.log.levels.WARN)
							end)
						else
							vim.schedule(function()
								vim.diagnostic.reset(bufnr) -- Limpiar diagnósticos antiguos
								vim.lsp.buf.refresh() -- Refrescar LSP
							end)
						end
					end,
				})
			end,
		})
	elseif client.name == "intelephense" then
		print("🐘 Intelephense conectado - Diagnósticos habilitados para buffer " .. bufnr)
		client.server_capabilities.documentFormattingProvider = false -- Usar php-cs-fixer
	elseif client.name == "ts_ls" then
		print("📜 TypeScript LSP conectado - Diagnósticos habilitados para buffer " .. bufnr)
		client.server_capabilities.documentFormattingProvider = false -- Usar Prettier
	elseif client.name == "pyright" then
		print("🐍 Pyright conectado - Diagnósticos habilitados para buffer " .. bufnr)
	elseif client.name == "jdtls" then
		print("☕ Java LSP conectado - Diagnósticos habilitados para buffer " .. bufnr)
	end

	-- Mensaje de confirmación
	vim.schedule(function()
		local diagnostics_count = #vim.diagnostic.get(bufnr)
		if diagnostics_count > 0 then
			vim.notify(
				string.format("LSP cargado - %d diagnósticos encontrados", diagnostics_count),
				vim.log.levels.INFO
			)
		else
			vim.notify("LSP cargado - Sin errores detectados ✅", vim.log.levels.INFO)
		end
	end)
end

-- Configuraciones específicas por servidor (solo servidores comunes)
local server_configs = {
	-- Configuración para Lua (útil para configurar Neovim)
	lua_ls = {
		on_attach = on_attach,
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = {
					globals = { "vim" },
					-- Configurar severidad de diagnósticos
					severity = {
						["undefined-global"] = "Error",
						["trailing-space"] = "Warning",
					},
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			},
		},
		flags = { debounce_text_changes = 150 },
	},
}

-- Servidores LSP comunes (que NO están en ningún perfil específico)
local standard_servers = { "html", "cssls", "jsonls" }

-- Configurar servidores con configuración personalizada
for server_name, config in pairs(server_configs) do
	lspconfig[server_name].setup(config)
end

-- Configurar servidores con configuración estándar
for _, server in ipairs(standard_servers) do
	lspconfig[server].setup({
		on_attach = on_attach,
		flags = { debounce_text_changes = 150 },
	})
end

-- Activar autocompletado
vim.o.completeopt = "menuone,noselect"

-- Función global para obtener estadísticas de diagnósticos
function _G.get_diagnostics_count()
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)
	local count = { errors = 0, warnings = 0, info = 0, hints = 0 }

	for _, diagnostic in ipairs(diagnostics) do
		if diagnostic.severity == vim.diagnostic.severity.ERROR then
			count.errors = count.errors + 1
		elseif diagnostic.severity == vim.diagnostic.severity.WARN then
			count.warnings = count.warnings + 1
		elseif diagnostic.severity == vim.diagnostic.severity.INFO then
			count.info = count.info + 1
		elseif diagnostic.severity == vim.diagnostic.severity.HINT then
			count.hints = count.hints + 1
		end
	end

	return count
end

-- Comando para mostrar estadísticas
vim.api.nvim_create_user_command("DiagnosticsInfo", function()
	local count = _G.get_diagnostics_count()
	local total = count.errors + count.warnings + count.info + count.hints

	if total == 0 then
		print("✅ Sin diagnósticos en el buffer actual")
	else
		print(
			string.format(
				"📊 Diagnósticos: %d errores, %d warnings, %d info, %d hints",
				count.errors,
				count.warnings,
				count.info,
				count.hints
			)
		)
	end
end, {})

-- Auto-comando para mostrar conteo al abrir archivos
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			vim.defer_fn(function()
				local count = _G.get_diagnostics_count()
				local total = count.errors + count.warnings + count.info + count.hints
				if total > 0 and count.errors > 0 then
					vim.notify(
						string.format("⚠️ %d errores encontrados - usa <leader>xe para ver detalles", count.errors),
						vim.log.levels.WARN
					)
				end
			end, 1000) -- Esperar 1 segundo para que el LSP termine de cargar
		end
	end,
})

return {}
