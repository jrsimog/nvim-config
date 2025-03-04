-- settings.lua - Configuración general de Neovim

local set = vim.opt

-- Configuración de interfaz
set.timeoutlen = 500 -- Reduce el tiempo de espera en combinaciones de teclas
set.number = true -- Mostrar números de línea
set.relativenumber = true -- Números de línea relativos
set.cursorline = true -- Resaltar la línea actual
set.termguicolors = true -- Habilitar colores en terminal
set.scrolloff = 8 -- Mantener espacio al hacer scroll
set.mouse = "a"
set.hlsearch = true
set.guifont = "JetBrainsMono Nerd Font:h10"
set.clipboard = "unnamedplus"
set.swapfile = false

-- Configuración de búsqueda
set.ignorecase = true -- Ignorar mayúsculas en búsquedas
set.smartcase = true -- Respetar mayúsculas si se usan en la búsqueda
set.hlsearch = true -- Resaltar coincidencias
set.incsearch = true -- Buscar en tiempo real

-- Configuración de tabulación
set.expandtab = true -- Convertir tabulaciones en espacios
set.shiftwidth = 2 -- Tamaño de la indentación
set.tabstop = 2 -- Tamaño de un tab
set.smartindent = true -- Identación inteligente

-- Desempeño
set.lazyredraw = true -- Evitar redibujado innecesario
set.updatetime = 300 -- Reduce el tiempo de espera para actualizaciones

vim.g.mapleader = " "  -- Define <leader> como la barra espaciadora
vim.g.maplocalleader = " "  -- Define <localleader> como la barra espaciadora también


vim.cmd("syntax on")
vim.cmd("set syntax=elixir")


function ChangeProfile(profile)
  local success, _ = pcall(require, "profiles." .. profile)
  if success then
    print("[✅] Perfil cambiado a: " .. profile)
  else
    print("[⚠️] Perfil '" .. profile .. "' no encontrado.")
  end
end

vim.api.nvim_create_user_command("ChangeProfile", function(opts)
  ChangeProfile(opts.args)
end, { nargs = 1 })
