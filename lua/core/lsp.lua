-- lua/core/lsp.lua - Configuración de LSP mejorada con diagnósticos y autocompletado

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
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

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

local server_configs = {
	lua_ls = {
		cmd = { "/home/jose/.asdf/shims/lua-language-server" }, -- ← AGREGAR ESTA LÍNEA
		filetypes = { "lua" },
		root_dir = function(fname)
			return vim.fs.root(fname, { ".luarc.json", ".luarc.jsonc", ".git" })
		end,
		capabilities = capabilities,
		on_attach = on_attach,
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
		flags = { debounce_text_changes = 150 },
	},
}

local standard_servers = { "html", "cssls", "jsonls" }

for server_name, config in pairs(server_configs) do
	vim.lsp.config(server_name, config)

	-- Activar el LSP automáticamente para los tipos de archivo correspondientes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = config.filetypes,
		callback = function()
			vim.lsp.enable(server_name)
		end,
	})
end

local server_filetypes = {
	html = { "html" },
	cssls = { "css", "scss", "less" },
	jsonls = { "json", "jsonc" },
}

local server_root_patterns = {
	html = { "package.json", ".git" },
	cssls = { "package.json", ".git" },
	jsonls = { "package.json", ".git" },
}

for _, server in ipairs(standard_servers) do
	vim.lsp.config(server, {
		filetypes = server_filetypes[server],
		root_dir = function(fname)
			return vim.fs.root(fname, server_root_patterns[server])
		end,
		capabilities = capabilities,
		on_attach = on_attach,
		flags = { debounce_text_changes = 150 },
	})

	-- Activar el LSP automáticamente para los tipos de archivo correspondientes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = server_filetypes[server],
		callback = function()
			vim.lsp.enable(server)
		end,
	})
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

return {
	capabilities = capabilities,
	on_attach = on_attach,
}
