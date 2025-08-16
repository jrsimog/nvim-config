-- lua/core/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Grupo de configuraciones generales
local general = augroup('GeneralSettings', { clear = true })

-- Resaltar al copiar
autocmd('TextYankPost', {
    group = general,
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end,
})

-- Restaurar la última posición del cursor
autocmd('BufReadPost', {
    group = general,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Eliminar espacios en blanco al final
autocmd('BufWritePre', {
    group = general,
    pattern = '*',
    command = [[%s/\s\+$//e]],
})

-- Grupo para detección automática de proyectos
local project_detection = augroup('ProjectDetection', { clear = true })

-- Detectar y cargar configuración de proyecto al entrar en un buffer
autocmd({ 'BufEnter', 'BufRead', 'BufNewFile', 'BufWinEnter', 'DirChanged' }, {
    group = project_detection,
    callback = function(event)
        -- Debug: mostrar información del evento
        local buftype = vim.bo[event.buf].buftype
        local filetype = vim.bo[event.buf].filetype
        local filename = vim.api.nvim_buf_get_name(event.buf)
        
        -- Uncomment for debugging:
        -- print("🔍 AutoCmd triggered - Event: " .. event.event .. ", File: " .. filename .. ", Type: " .. filetype)
        
        -- No ejecutar en buffers especiales, terminales, help, etc.
        if buftype ~= '' or 
           filetype == 'alpha' or 
           filetype == 'TelescopePrompt' or 
           filetype == 'TelescopeResults' or
           filetype == 'neo-tree' or
           filetype == 'NvimTree' or
           filetype == 'help' or
           filetype == 'qf' then
            -- print("🔍 Skipping due to special buffer type: " .. filetype .. " (" .. buftype .. ")")
            return
        end
        
        -- Solo ejecutar si tenemos un archivo real
        if filename == '' or not vim.fn.filereadable(filename) then
            -- print("🔍 Skipping due to no readable file: " .. filename)
            return
        end
        
        -- print("🔍 Loading project config for: " .. filename)
        local project = require('core.project')
        project.load_project_config()
        
        -- Debug: verificar LSP después de cargar
        -- vim.schedule(function()
        --     local clients = vim.lsp.get_clients()
        --     print("🔍 LSP clients after loading: " .. #clients)
        --     for _, client in ipairs(clients) do
        --         print("  - " .. client.name .. " (id: " .. client.id .. ")")
        --     end
        -- end)
    end,
})

-- Autocomando adicional específico para archivos PHP como backup
autocmd('FileType', {
    group = project_detection,
    pattern = 'php',
    callback = function(event)
        -- print("🐘 PHP FileType detected - forcing profile load")
        vim.schedule(function()
            local project = require('core.project')
            project.load_project_config('php')
        end)
    end,
})

