-- lua/profiles/default.lua - Perfil por defecto (configuración genérica)

local M = {}

-- Configuración genérica que se aplicará cuando no se detecte un tipo de proyecto específico
function M.setup()
    -- Configuraciones básicas que aplican a cualquier proyecto
    vim.notify('Default profile loaded - no specific project type detected', vim.log.levels.INFO)
    
    -- Configuraciones generales que no son específicas de ningún lenguaje
    -- Puedes añadir aquí configuraciones que quieras aplicar por defecto
end

return M
