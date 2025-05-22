-- lua/core/editor.lua
-- Asegúrate de incluir esta configuración en un lugar que se ejecute durante la inicialización de Neovim
vim.cmd([[
  autocmd FileType diff setlocal foldmethod=manual foldlevel=999
  autocmd BufWinEnter,WinEnter * if &diff | set foldlevel=999 | endif
]])

-- Estilo vertical para diffs (ideal para git mergetool)
vim.opt.diffopt:append("vertical")

-- Mensaje cuando entras en un merge conflict
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.filereadable(".git/MERGE_HEAD") == 1 then
            print("🌪️  Resolviendo un merge… usa <leader>do y <leader>dt para elegir lados.")
        end
    end
})
