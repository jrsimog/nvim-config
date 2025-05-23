-- init.lua - Configuración modular para Neovim con Lazy.nvim
-- Cargar Lazy.nvim
local lazypath = vim.fn.stdpath("config") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Cargar la configuración modular
require("core.settings")
require("core.keymaps")
require("core.plugins") -- Lazy.nvim se carga aquí
require("core.lsp")
require("core.autocomplete")
require("core.theme")
require("core.dap") -- Depuración con DAP
require("core.editor")
require("core.projectionist")

-- Función para cargar y configurar el prompt de IA específico del perfil
local function load_and_set_ai_prompt(profile_name)
    local profile_name_to_load = profile_name
    local prompt_path = vim.fn.stdpath("config") .. "/lua/prompts/" .. profile_name_to_load .. ".lua"
    local default_prompt_path = vim.fn.stdpath("config") .. "/lua/prompts/default.lua"
    local generic_fallback_prompt = "You are a helpful AI assistant."
    local prompt_to_set = generic_fallback_prompt -- Inicia con el fallback genérico

    local notify_opts = { title = "AI Prompt" }

    -- Intentar cargar el prompt del perfil
    local ok, loaded_str = pcall(dofile, prompt_path)
    if ok and type(loaded_str) == "string" and #loaded_str > 0 then
        prompt_to_set = loaded_str
        vim.notify("Prompt for profile '" .. profile_name_to_load .. "' loaded.", vim.log.levels.INFO, notify_opts)
    else
        if not ok then
            vim.notify("Error loading prompt for profile '" .. profile_name_to_load .. "': " .. tostring(loaded_str) .. ". Trying default.", vim.log.levels.WARN, notify_opts)
        elseif type(loaded_str) ~= "string" or #loaded_str == 0 then
            -- Esto también cubre el caso de vim.fn.filereadable(prompt_path) == 0 porque dofile fallaría
            vim.notify("Prompt file for profile '" .. profile_name_to_load .. "' not found, empty, or invalid. Trying default.", vim.log.levels.WARN, notify_opts)
        end

        -- Intentar cargar el prompt por defecto
        local default_ok, default_loaded_str = pcall(dofile, default_prompt_path)
        if default_ok and type(default_loaded_str) == "string" and #default_loaded_str > 0 then
            prompt_to_set = default_loaded_str
            vim.notify("Default prompt loaded.", vim.log.levels.INFO, notify_opts)
        else
            if not default_ok then
                vim.notify("Error loading default prompt: " .. tostring(default_loaded_str) .. ". Using hardcoded default.", vim.log.levels.WARN, notify_opts)
            elseif type(default_loaded_str) ~= "string" or #default_loaded_str == 0 then
                vim.notify("Default prompt is empty or invalid. Using hardcoded default.", vim.log.levels.WARN, notify_opts)
            end
            -- Si prompt_to_set sigue siendo el genérico, notificar que se está usando el hardcoded.
            if prompt_to_set == generic_fallback_prompt then
                 vim.notify("Using hardcoded default system prompt for Avante.", vim.log.levels.INFO, notify_opts)
            end
        end
    end

    -- Después de determinar prompt_to_set, intentar actualizar Avante
    local avante_config_ok, avante_config = pcall(require, "avante.config")
    if avante_config_ok and avante_config and type(avante_config.override) == "function" then
        local override_ok, override_err = pcall(avante_config.override, { system_prompt = prompt_to_set })
        if override_ok then
            vim.notify("Avante system_prompt updated for profile '" .. profile_name_to_load .. "'.", vim.log.levels.INFO, notify_opts)
        else
            vim.notify("Error overriding Avante system_prompt: " .. tostring(override_err), vim.log.levels.ERROR, notify_opts)
        end
    else
        if not avante_config_ok then
             vim.notify("Failed to load avante.config: " .. tostring(avante_config) .. ". Prompt will be set when Avante loads.", vim.log.levels.WARN, notify_opts)
        else
             vim.notify("avante.config.override not available or not a function. Prompt will be set when Avante loads.", vim.log.levels.WARN, notify_opts)
        end
    end
end

-- Funciones mejoradas para manejo de perfiles
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

-- Función para listar perfiles disponibles
local function list_profiles()
    local profiles_dir = vim.fn.stdpath("config") .. "/lua/profiles"

    -- Verificar si el directorio existe
    if vim.fn.isdirectory(profiles_dir) ~= 1 then
        print("[❌] Directorio de perfiles no encontrado: " .. profiles_dir)
        return
    end

    -- Obtener la lista de archivos .lua en el directorio
    local files = vim.fn.globpath(profiles_dir, "*.lua", false, true)

    if #files == 0 then
        print("[❓] No se encontraron perfiles en: " .. profiles_dir)
        return
    end

    -- Extraer los nombres de perfiles (sin la extensión .lua)
    print("[📋] Perfiles disponibles:")
    for _, file_path in ipairs(files) do
        local file_name = vim.fn.fnamemodify(file_path, ":t:r") -- Obtiene el nombre sin ruta ni extensión
        print("    - " .. file_name)
    end

    -- Mostrar el perfil actual
    local current_profile = os.getenv("NVIM_PROFILE") or "elixir"
    print("[👉] Perfil actual: " .. current_profile)
end

-- Función mejorada para cambiar de perfil
local function change_profile(profile)
    local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua"

    -- Verificar si el archivo existe
    if vim.fn.filereadable(profile_path) ~= 1 then
        print("[❌] Perfil '" .. profile .. "' no encontrado en: " .. profile_path)
        return
    end

    -- Limpiar caché para asegurar que se cargue la versión más reciente
    package.loaded["profiles." .. profile] = nil

    -- Intentar cargar el perfil usando pcall
    local success, result = pcall(require, "profiles." .. profile)

    if success then
        -- Guardar el perfil actual en una variable de entorno
        vim.env.NVIM_PROFILE = profile
        print("[✅] Perfil cambiado a: " .. profile)
        load_and_set_ai_prompt(profile) -- Cargar prompt de IA
    else
        print("[⚠️] Error al cargar el perfil '" .. profile .. "':")
        print(result) -- Muestra el error específico

        -- Intentar abrir el archivo directamente con dofile como alternativa
        print("[🔄] Intentando cargar con dofile...")
        local dofile_success, dofile_error = pcall(dofile, profile_path)

        if dofile_success then
            vim.env.NVIM_PROFILE = profile
            print("[✅] Perfil cargado con dofile exitosamente.")
            load_and_set_ai_prompt(profile) -- Cargar prompt de IA
        else
            print("[❌] También falló con dofile: " .. tostring(dofile_error))
        end
    end
end

-- Crear los comandos para manejar perfiles
vim.api.nvim_create_user_command("ListProfiles", function()
    list_profiles()
end, {})

vim.api.nvim_create_user_command("ChangeProfile", function(opts)
    change_profile(opts.args)
end, {
    nargs = 1,
    complete = function()
        return list_available_profiles()
    end
})

-- Manejo de perfiles al inicio
do
    local profile = os.getenv("NVIM_PROFILE") or "elixir" -- Ahora Elixir es el perfil por defecto
    local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua"

    -- Verificar si el archivo existe antes de intentar cargarlo
    if vim.fn.filereadable(profile_path) ~= 1 then
        print("[⚠️] Perfil '" .. profile .. "' no encontrado. Cargando perfil de Elixir.")
        profile = "elixir"
    end

    -- Intentar cargar el perfil
    local success, err = pcall(require, "profiles." .. profile)
    if success then
        load_and_set_ai_prompt(profile) -- Cargar prompt de IA para el perfil inicial
    else
        print("[❌] Error al cargar el perfil '" .. profile .. "': " .. tostring(err))
        print("[🔄] Intentando cargar con dofile...")
        local dofile_success, dofile_err = pcall(dofile, vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua")
        if dofile_success then
            load_and_set_ai_prompt(profile) -- Cargar prompt de IA si dofile tuvo éxito
        else
            print("[❌] Error al cargar el perfil '" .. profile .. "' con dofile: " .. tostring(dofile_err))
        end
    end
end

-- Asegurar que Neovim detecta los tipos de archivos correctamente
vim.cmd("filetype on")
vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")
