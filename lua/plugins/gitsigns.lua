-- lua/plugins/gitsigns.lua
local function setup_plugin(name, config)
  local status_ok, plugin = pcall(require, name)
  if status_ok then
    plugin.setup(config or {})
  else
    vim.notify('Plugin ' .. name .. ' no encontrado', vim.log.levels.WARN)
  end
end

setup_plugin('gitsigns')
