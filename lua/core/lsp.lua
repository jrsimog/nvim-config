-- lsp.lua - Configuración de LSP en Neovim

local lspconfig = require('lspconfig')

-- Servidores LSP disponibles
local servers = { 'elixirls', 'ts_ls', 'pyright', 'gopls', 'rust_analyzer' }

for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = function(client, bufnr)
      local buf_map = vim.api.nvim_buf_set_keymap
      local opts = { noremap = true, silent = true }
      buf_map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_map(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_map(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_map(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    end,
    flags = {
      debounce_text_changes = 150,
    }
  })
end

-- Activar autocompletado
vim.o.completeopt = 'menuone,noselect'

