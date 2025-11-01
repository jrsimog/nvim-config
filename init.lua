-- init.lua - Configuración modular para Neovim con Lazy.nvim

-- Configurar PATH para que Mason encuentre herramientas de ASDF
vim.env.PATH = vim.env.HOME .. "/.asdf/shims:" .. vim.env.PATH

local lazypath = vim.fn.stdpath("config") .. "/lazy/lazy.nvim"
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

require("core.settings")
require("core.keymaps")
require("core.plugins")  -- This will load LSP via lazy.nvim
-- require("core.lsp")  -- NO LONGER NEEDED - loaded by lazy.nvim in plugins.lua
require("core.autocomplete")
require("core.theme")
require("core.dap")
require("core.editor")
require("core.projectionist")
require("core.copilot")
require("core.autocmds")

local function list_available_profiles()
	local profiles_dir = vim.fn.stdpath("config") .. "/lua/profiles"
	local files = vim.fn.globpath(profiles_dir, "*.lua", false, true)
	local profiles = {}

	for _, file_path in ipairs(files) do
		local profile_name = vim.fn.fnamemodify(file_path, ":t:r")
		table.insert(profiles, profile_name)
	end

	return profiles
end

local function list_profiles()
	local profiles_dir = vim.fn.stdpath("config") .. "/lua/profiles"

	if vim.fn.isdirectory(profiles_dir) ~= 1 then
		print("[❌] Directorio de perfiles no encontrado: " .. profiles_dir)
		return
	end

	local files = vim.fn.globpath(profiles_dir, "*.lua", false, true)

	if #files == 0 then
		print("[❓] No se encontraron perfiles en: " .. profiles_dir)
		return
	end

	print("[📋] Perfiles disponibles:")
	for _, file_path in ipairs(files) do
		local file_name = vim.fn.fnamemodify(file_path, ":t:r") -- Obtiene el nombre sin ruta ni extensión
		print("    - " .. file_name)
	end

	local current_profile = os.getenv("NVIM_PROFILE") or "elixir"
	print("[👉] Perfil actual: " .. current_profile)
end

local function change_profile(profile)
	local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua"

	if vim.fn.filereadable(profile_path) ~= 1 then
		print("[❌] Perfil '" .. profile .. "' no encontrado en: " .. profile_path)
		return
	end

	package.loaded["profiles." .. profile] = nil

	local success, result = pcall(require, "profiles." .. profile)

	if success then
		vim.env.NVIM_PROFILE = profile
		print("[✅] Perfil cambiado a: " .. profile)
	else
		print("[⚠️] Error al cargar el perfil '" .. profile .. "':")
		print(result)

		print("[🔄] Intentando cargar con dofile...")
		local dofile_success, dofile_error = pcall(dofile, profile_path)

		if dofile_success then
			vim.env.NVIM_PROFILE = profile
			print("[✅] Perfil cargado con dofile exitosamente.")
		else
			print("[❌] También falló con dofile: " .. tostring(dofile_error))
		end
	end
end

vim.api.nvim_create_user_command("ListProfiles", function()
	list_profiles()
end, {})

vim.api.nvim_create_user_command("ChangeProfile", function(opts)
	change_profile(opts.args)
end, {
	nargs = 1,
	complete = function()
		return list_available_profiles()
	end,
})

-- Comandos de diagnóstico para el sistema automático
vim.api.nvim_create_user_command("ProjectDebug", function()
	local project = require('core.project')
	project.debug_status()
end, { desc = "Debug project detection system" })

vim.api.nvim_create_user_command("ProjectReload", function()
	local project = require('core.project')
	project.reload_current_project()
end, { desc = "Force reload current project profile" })

-- Comando de test para verificar el sistema
vim.api.nvim_create_user_command("TestPhpProfile", function()
	print("🧪 Testing PHP profile loading...")
	package.loaded["profiles.php"] = nil
	local success, result = pcall(require, "profiles.php")
	if success and type(result.setup) == 'function' then
		result.setup()
		print("✅ PHP profile loaded successfully!")
	else
		print("❌ Error loading PHP profile: " .. tostring(result))
	end
end, { desc = "Test PHP profile loading" })

-- Comando para verificar LSP manualmente
vim.api.nvim_create_user_command("TestLspCapabilities", function()
	local clients = vim.lsp.get_clients()
	print("🔍 Active LSP clients:")
	for _, client in ipairs(clients) do
		print("- " .. client.name .. " (id: " .. client.id .. ")")
		if client.server_capabilities.definitionProvider then
			print("  ✅ Supports go to definition")
		else
			print("  ❌ Does NOT support go to definition")
		end
	end
	if #clients == 0 then
		print("❌ No active LSP clients found")
	end
end, { desc = "Test LSP capabilities" })

-- Comando para verificar que el autocomando existe
vim.api.nvim_create_user_command("TestAutoCommands", function()
	print("🔍 Checking autocmds:")
	local autocmds = vim.api.nvim_get_autocmds({ group = "ProjectDetection" })
	if #autocmds > 0 then
		print("✅ ProjectDetection autocmds found: " .. #autocmds)
		for _, cmd in ipairs(autocmds) do
			print("  - Event: " .. cmd.event .. ", Pattern: " .. (cmd.pattern or "none"))
		end
	else
		print("❌ No ProjectDetection autocmds found")
	end
end, { desc = "Test autocmds" })

-- Comando para forzar activación en buffer actual
vim.api.nvim_create_user_command("ForceProjectDetection", function()
	print("🔧 Forcing project detection on current buffer...")
	local project = require('core.project')
	project.load_project_config()
	print("✅ Project detection forced")
end, { desc = "Force project detection" })

-- Comando para probar Intelephense directamente
vim.api.nvim_create_user_command("TestIntelephense", function()
	print("🧪 Testing Intelephense directly...")
	local lspconfig = require("lspconfig")
	
	-- Verificar que intelephense esté en PATH
	local cmd = vim.fn.exepath("intelephense")
	if cmd == "" then
		print("❌ Intelephense not found in PATH")
		return
	end
	print("✅ Intelephense found at: " .. cmd)
	
	-- Configurar Intelephense directamente
	lspconfig.intelephense.setup({
		cmd = { "intelephense", "--stdio" },
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		on_attach = function(client, bufnr)
			print("🐘 Intelephense attached successfully to buffer " .. bufnr)
		end,
		filetypes = { "php" },
		root_dir = function(fname)
			return lspconfig.util.find_git_ancestor(fname) or lspconfig.util.path.dirname(fname)
		end,
	})
	
	print("✅ Intelephense configuration sent")
end, { desc = "Test Intelephense directly" })

do
	local profile = os.getenv("NVIM_PROFILE") or "elixir" -- Ahora Elixir es el perfil por defecto
	local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua"

	if vim.fn.filereadable(profile_path) ~= 1 then
		print("[⚠️] Perfil '" .. profile .. "' no encontrado. Cargando perfil de Elixir.")
		profile = "elixir"
	end

	local success, err = pcall(require, "profiles." .. profile)
	if not success then
		print("[❌] Error al cargar el perfil '" .. profile .. "': " .. tostring(err))
		print("[🔄] Intentando cargar con dofile...")
		pcall(dofile, vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua")
	end
end

vim.cmd("filetype on")
vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")
