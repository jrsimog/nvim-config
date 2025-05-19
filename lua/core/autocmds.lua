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

