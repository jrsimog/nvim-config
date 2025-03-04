-- editor.lua
-- Asegúrate de incluir esta configuración en un lugar que se ejecute durante la inicialización de Neovim
vim.cmd([[
  autocmd FileType diff setlocal foldmethod=manual foldlevel=999
  autocmd BufWinEnter,WinEnter * if &diff | set foldlevel=999 | endif
]])

