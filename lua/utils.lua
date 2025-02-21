-- utils.lua - Funciones auxiliares para Neovim

local M = {}

-- Función para verificar si un plugin está instalado
M.is_plugin_installed = function(name)
  local status_ok, _ = pcall(require, name)
  return status_ok
end

-- Función para imprimir mensajes en Neovim
M.notify = function(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Neovim' })
end

-- Función para recargar configuraciones rápidamente
M.reload_config = function()
  for name, _ in pairs(package.loaded) do
    if name:match('^core') or name:match('^profiles') then
      package.loaded[name] = nil
    end
  end
  vim.cmd('source ~/.config/nvim/init.vim')
  M.notify('Configuración recargada!', vim.log.levels.INFO)
end

return M


