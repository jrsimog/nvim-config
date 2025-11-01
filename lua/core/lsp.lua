-- lua/core/lsp.lua - Configuración de LSP con Mason para gestión automática

-- Verificar que lspconfig esté disponible (cargado por lazy.nvim)
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
	-- Si lspconfig no está disponible, retornar funciones dummy
	-- Esto evita errores durante el bootstrap inicial
	_G.get_lsp_config = function()
		return {
			capabilities = vim.lsp.protocol.make_client_capabilities(),
			on_attach = function() end,
			flags = {},
		}
	end
	_G.register_profile_lsp = function() end
	_G.is_lsp_configured_by_profile = function() return false end
	_G.show_profile_lsps = function() print("❌ LSP not loaded yet") end
	_G.get_diagnostics_count = function() return { errors = 0, warnings = 0, info = 0, hints = 0 } end
	return
end

-- Suprimir advertencia de deprecación de lspconfig temporalmente
local notify_ok, notify_module = pcall(require, "notify")
if notify_ok then
	local original_notify = vim.notify
	vim.notify = function(msg, level, opts)
		if type(msg) == "string" and msg:match("lspconfig.*deprecated") then
			return -- Ignorar advertencias de deprecación de lspconfig
		end
		return notify_module(msg, level, opts)
	end
end

-- Verificar si Mason está disponible (puede no estar instalado aún)
local mason_ok, mason = pcall(require, "mason")
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")

-- Verificaciones silenciosas - solo mostrar cuando hay problemas
if not mason_ok then
	print("⚠️ Mason no disponible - será instalado por Lazy")
end

if not mason_lspconfig_ok then
	print("⚠️ Mason-lspconfig no disponible - será instalado por Lazy")
end

-- Configurar capabilities para autocompletado
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
else
	print("⚠️ cmp_nvim_lsp no encontrado - autocompletado limitado")
end

vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		prefix = "●",
		source = "always",
		format = function(diagnostic)
			local message = diagnostic.message
			if #message > 50 then
				return string.sub(message, 1, 50) .. "..."
			end
			return message
		end,
	},
	float = {
		enabled = true,
		source = "always",
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
		priority = 8,
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

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

local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	local group = vim.api.nvim_create_augroup("lsp_diagnostics_" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		buffer = bufnr,
		callback = function()
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

	if client.name == "elixirls" then
		print("⚗️ ElixirLS conectado - Diagnósticos habilitados para buffer " .. bufnr)
		client.server_capabilities.documentFormattingProvider = true

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = group,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	elseif client.name == "intelephense" then
		print("🐘 Intelephense conectado - Diagnósticos habilitados para buffer " .. bufnr)
		client.server_capabilities.documentFormattingProvider = false
	elseif client.name == "ts_ls" then
		print("📜 TypeScript LSP conectado - Diagnósticos habilitados para buffer " .. bufnr)
		client.server_capabilities.documentFormattingProvider = false
	elseif client.name == "pyright" then
		print("🐍 Pyright conectado - Diagnósticos habilitados para buffer " .. bufnr)
	elseif client.name == "jdtls" then
		print("☕ Java LSP conectado - Diagnósticos habilitados para buffer " .. bufnr)
	end

	vim.schedule(function()
		local diagnostics_count = #vim.diagnostic.get(bufnr)
		if diagnostics_count > 0 then
			vim.notify(
				string.format("LSP cargado - %d diagnósticos encontrados", diagnostics_count),
				vim.log.levels.INFO
			)
		else
			-- vim.notify("LSP cargado - Sin errores detectados ✅", vim.log.levels.INFO)
		end
	end)
end

-- ========================================
-- CONFIGURACIÓN AUTOMÁTICA CON MASON
-- ========================================

if mason_ok and mason_lspconfig_ok then
	-- Lista de servidores LSP que queremos que Mason instale automáticamente
	local servers = {
		"lua_ls",      -- Lua
		"elixirls",    -- Elixir
		"intelephense", -- PHP
		"ts_ls",       -- TypeScript/JavaScript (antes tsserver)
		"pyright",     -- Python
		"jdtls",       -- Java
		"bashls",      -- Bash/Zsh
		"html",        -- HTML
		"cssls",       -- CSS
		"jsonls",      -- JSON
		"yamlls",      -- YAML
	}

	-- Verificar que mason_lspconfig tiene el método setup
	if mason_lspconfig.setup then
		mason_lspconfig.setup({
			ensure_installed = servers,
			automatic_installation = true,
		})
		-- Mason-lspconfig configurado silenciosamente
	else
		print("❌ Mason-lspconfig.setup no disponible")
	end
else
	print("⚠️ Mason no disponible - usando configuración LSP básica")
end

-- Configuraciones específicas para algunos servidores
local server_configs = {
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = {
					globals = { "vim" },
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
	},
	intelephense = {
		settings = {
			intelephense = {
				files = {
					maxSize = 1000000,
				},
			},
		},
	},
	ts_ls = {
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "literal",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
	},
}

-- ========================================
-- CONFIGURACIÓN CON MASON-LSPCONFIG v2.x
-- ========================================
-- En mason-lspconfig v2.x, los LSPs se habilitan automáticamente con vim.lsp.enable()
-- Solo necesitamos configurar on_attach y capabilities usando vim.lsp.config()

-- LSPs que TIENEN perfil específico y NO deben configurarse aquí automáticamente
local profile_managed_servers = {
	"elixirls",    -- Gestionado por profiles/elixir.lua
	"intelephense", -- Gestionado por profiles/php.lua
	"jdtls",       -- Gestionado por profiles/java.lua (si existe)
	"pyright",     -- Gestionado por profiles/python.lua (si existe)
	"bashls",      -- Gestionado por profiles/sh.lua
}

-- Configurar LSPs que NO son gestionados por perfiles usando la nueva API vim.lsp.config()
-- Esto se aplica automáticamente cuando mason-lspconfig los habilita
if mason_lspconfig_ok then
	for server_name, config in pairs(server_configs) do
		-- Solo configurar si NO es gestionado por un perfil
		local is_profile_managed = false
		for _, managed in ipairs(profile_managed_servers) do
			if server_name == managed then
				is_profile_managed = true
				break
			end
		end

		if not is_profile_managed then
			-- Usar la nueva API vim.lsp.config() si está disponible (Neovim 0.11+)
			if vim.lsp.config then
				vim.lsp.config(server_name, {
					capabilities = capabilities,
					on_attach = on_attach,
					flags = { debounce_text_changes = 150 },
					settings = config.settings or {},
				})
			else
				-- Fallback para Neovim < 0.11: usar lspconfig directamente
				local full_config = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
					on_attach = on_attach,
					flags = { debounce_text_changes = 150 },
				}, config)
				lspconfig[server_name].setup(full_config)
			end
		end
	end
else
	print("❌ Mason-lspconfig no disponible - LSPs no se configurarán automáticamente")
	print("💡 Ejecuta :Lazy sync para instalar los plugins")
end

vim.o.completeopt = "menuone,noselect"

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
			end, 1000)
		end
	end,
})

-- ========================================
-- COMANDOS ÚTILES PARA MASON
-- ========================================

-- Comando para verificar el estado de Mason
vim.api.nvim_create_user_command("MasonStatus", function()
	if not mason_ok then
		print("❌ Mason no está disponible")
		print("💡 Reinicia Neovim para que Lazy instale los plugins")
		return
	end

	local registry_ok, registry = pcall(require, "mason-registry")
	if not registry_ok then
		print("❌ Mason registry no disponible")
		return
	end

	local installed = registry.get_installed_packages()

	print("📦 Estado de Mason:")
	print("Paquetes instalados: " .. #installed)

	for _, pkg in ipairs(installed) do
		print("  ✅ " .. pkg.name)
	end

	print("\n🔧 Para gestionar paquetes usa:")
	print("  :Mason - Abrir interfaz gráfica")
	print("  :MasonUpdate - Actualizar todos")
	print("  :MasonLog - Ver logs")
end, { desc = "Mostrar estado de Mason y paquetes instalados" })

-- Comando para verificar qué perfiles han configurado LSPs
vim.api.nvim_create_user_command("ProfileLSPs", function()
	_G.show_profile_lsps()
	print("\n🔍 Estado actual:")
	local clients = vim.lsp.get_clients()
	if #clients > 0 then
		print("LSPs activos:")
		for _, client in ipairs(clients) do
			print("  ✅ " .. client.name .. " (id: " .. client.id .. ")")
		end
	else
		print("❌ No hay LSPs activos")
	end
end, { desc = "Mostrar LSPs configurados por perfiles" })

-- ========================================
-- FUNCIONES PARA PERFILES
-- ========================================

-- Función para que los perfiles obtengan configuración base
function _G.get_lsp_config()
	return {
		capabilities = capabilities,
		on_attach = on_attach,
		flags = { debounce_text_changes = 150 },
	}
end

-- Función para que los perfiles registren que han configurado un LSP
local profile_configured_lsps = {}
function _G.register_profile_lsp(server_name, profile_name)
	profile_configured_lsps[server_name] = profile_name
	-- print("📝 LSP " .. server_name .. " registrado por perfil " .. profile_name)
end

-- Función para verificar si un LSP ya fue configurado por un perfil
function _G.is_lsp_configured_by_profile(server_name)
	return profile_configured_lsps[server_name] ~= nil
end

-- Función para debug
function _G.show_profile_lsps()
	print("📋 LSPs configurados por perfiles:")
	for server, profile in pairs(profile_configured_lsps) do
		print("  - " .. server .. " → " .. profile)
	end
end

return {
	capabilities = capabilities,
	on_attach = on_attach,
}
