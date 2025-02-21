-- lua/plugins/treesitter.lua

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup({
  ensure_installed = { "lua", "vim", "javascript", "typescript", "php" },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
