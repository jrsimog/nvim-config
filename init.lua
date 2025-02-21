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
require("core.plugins")  -- Lazy.nvim se carga aquí
require("core.lsp")
require("core.autocomplete")
require("core.theme")
require("core.dap") -- Depuración con DAP

-- Manejo de perfiles
do
  local profile = os.getenv("NVIM_PROFILE") or "default"
  local success, _ = pcall(require, "profiles." .. profile)
  if not success then
    print("[Warning] Perfil '" .. profile .. "' no encontrado. Cargando perfil por defecto.")
    require("profiles.default")
  end
end

-- Asegurar que Neovim detecta los tipos de archivos correctamente
vim.cmd("filetype on")
vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")

