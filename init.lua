-- init.lua - Configuración modular para Neovim con Lazy.nvim
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
require("core.plugins")
require("core.lsp")
require("core.autocomplete")
require("core.theme")
require("core.dap")
require("core.editor")
require("core.projectionist")

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
