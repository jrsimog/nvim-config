-- frontend.lua - Perfil simplificado para desarrollo Frontend
local M = {}

-- Configurar LSP para desarrollo frontend
local function setup_lsp()
  local lspconfig = require('lspconfig')

  -- Configurar TypeScript/JavaScript Language Server
  pcall(function()
    lspconfig.ts_ls.setup({
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      on_attach = function(client, bufnr)
        -- Deshabilitar formateo del TSServer (usaremos Prettier)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    })
  end)

  -- Configurar CSS Language Server
  pcall(function()
    lspconfig.cssls.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      filetypes = { "css", "scss", "less" }
    })
  end)

  -- Configurar HTML Language Server
  pcall(function()
    lspconfig.html.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      filetypes = { "html" }
    })
  end)

  -- Configurar JSON Language Server
  pcall(function()
    lspconfig.jsonls.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      filetypes = { "json", "jsonc" }
    })
  end)

  -- Configurar ESLint
  pcall(function()
    lspconfig.eslint.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" }
    })
  end)
end

-- Configurar indentación para archivos frontend
local function setup_indentation()
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.js", "*.jsx", "*.ts", "*.tsx", "*.vue", "*.css", "*.scss", "*.html", "*.json"},
    callback = function()
      -- Configurar indentación para archivos frontend (2 espacios es lo estándar)
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
    end,
  })

  -- Configuración para formateo automático al guardar
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*.js", "*.jsx", "*.ts", "*.tsx", "*.vue", "*.css", "*.scss", "*.html", "*.json"},
    callback = function()
      pcall(function() vim.lsp.buf.format({ async = false }) end)
    end,
  })
end

-- Configurar Emmet para HTML/JSX - VERSIÓN CORREGIDA
local function setup_emmet()
  vim.g.user_emmet_mode = 'a' -- Habilitar Emmet en todos los modos
  vim.g.user_emmet_leader_key = '<C-e>'
  
  -- Usamos la sintaxis de índices de tabla para evitar palabras reservadas como 'for'
  vim.g.user_emmet_settings = {
    javascript = {
      extends = 'jsx',
      attribute_name = {
        ["class"] = 'className',
        ["for"] = 'htmlFor'
      }
    },
    typescript = {
      extends = 'jsx'
    },
    typescriptreact = {
      extends = 'jsx'
    }
  }
end

-- Configurar soporte para React, JSX y comandos específicos
local function setup_react_support()
  -- Configurar filetype para extensiones JSX/TSX
  vim.cmd([[
  autocmd BufNewFile,BufRead *.jsx,*.tsx setlocal filetype=typescriptreact
  autocmd BufNewFile,BufRead *.js,*.ts setlocal filetype=javascript
  ]])
end

-- Cargar keymaps específicos para frontend
local function load_keymaps()
  -- Comprobamos si existe el archivo de keymaps de frontend
  -- local ok, _ = pcall(require, "keymaps.frontend")
  if not ok then
    -- Si no existe, definimos algunos keymaps básicos aquí
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    
    -- Formateo y linting para frontend
    map('n', '<leader>fep', ':lua vim.lsp.buf.format()<CR>', opts)
    map('n', '<leader>fee', ':EslintFixAll<CR>', opts)
    
    -- Navegación en proyectos React
    map('n', '<leader>fec', ':Telescope find_files cwd=src/components<CR>', opts)
    map('n', '<leader>fep', ':Telescope find_files cwd=src/pages<CR>', opts)
    
    print("[ℹ️] Usando keymaps básicos de frontend. Para más funcionalidades, crea el archivo keymaps/frontend.lua")
  else
    print("[✅] Keymaps de frontend cargados correctamente")
  end
end

-- Función de inicialización
function M.setup()
  print("[🚀] Iniciando perfil de Frontend...")
  
  -- Configurar LSP
  pcall(function() setup_lsp() end)
  
  -- Configurar indentación
  pcall(function() setup_indentation() end)
  
  -- Configurar Emmet
  pcall(function() setup_emmet() end)
  
  -- Configurar soporte React
  pcall(function() setup_react_support() end)
  
  -- Cargar keymaps
  pcall(function() load_keymaps() end)
  
  print("[✅] Perfil Frontend cargado correctamente!")
end

-- Inicializar el perfil automáticamente
M.setup()

-- Retornar el módulo
return M
