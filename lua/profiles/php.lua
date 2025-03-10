-- php.lua - Perfil para PHP, Symfony y Laravel
print("🐘 Cargando perfil PHP con Symfony y Laravel")
local lspconfig = require("lspconfig")

-- Configuración de cliente personalizada para Intelephense
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.intelephense.setup({
  capabilities = capabilities,
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      completion = { 
        fullyQualifyGlobalConstantsAndFunctions = true,
        insertUseDeclaration = true,
        maxItems = 100,
      },
      trace = { server = "messages" }
    }
  },
  -- Esta es la parte clave: agregar comandos personalizados que se ejecutan cuando el servidor está listo
  on_attach = function(client, bufnr)
    -- Establecer capacidades del buffer
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Crear función para importar clase bajo el cursor
    vim.api.nvim_buf_create_user_command(bufnr, 'PhpImportClass', function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.addMissingImports" }
        }
      })
    end, {})
    
    -- Crear keymap específico de buffer para importar clase (Ctrl+Enter)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-CR>', ':PhpImportClass<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-CR>', '<Esc>:PhpImportClass<CR>a', { noremap = true, silent = true })
    
    -- Configurar autocommand para importación automática al completar una clase
    -- Este evento ocurre después de que se completa una palabra
    vim.api.nvim_create_autocmd("CompleteDone", {
      buffer = bufnr,
      callback = function()
        local completed_item = vim.v.completed_item
        if completed_item and completed_item.user_data and completed_item.user_data.lspitem and 
           completed_item.user_data.lspitem.kind == 7 then -- El tipo 7 corresponde a una clase
          vim.defer_fn(function()
            vim.cmd("PhpImportClass")
          end, 100) -- Pequeño retraso para asegurar que la compleción se procese primero
        end
      end,
    })
    
    print("✅ Intelephense conectado con importación automática para PHP")
  end
})

-- Configuración existente
vim.g.laravel_cache = 1
vim.api.nvim_set_keymap('n', '<leader>pl', ':Laravel<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>ps', ':!symfony server:start<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>pc', ':!symfony console<CR>', { noremap = true, silent = true }) 

-- Formateo automático con php-cs-fixer antes de guardar
vim.cmd [[autocmd BufWritePre *.php lua vim.lsp.buf.format()]]

-- Crear comandos globales útiles
vim.api.nvim_create_user_command("PhpIndexRefresh", function()
  vim.cmd("LspRestart intelephense")
  print("🔄 Reiniciando indexación de PHP...")
end, {})

vim.api.nvim_create_user_command("PhpImport", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source.addMissingImports" }
    }
  })
end, {})

print("✅ Perfil PHP cargado con soporte de importación automática")
print("🐘 Cargando perfil PHP con Symfony y Laravel")
local lspconfig = require("lspconfig")

-- Configuración mejorada de Intelephense
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 5000000 },
      diagnostics = { enable = true },
      -- Mejoras para la importación automática
      completion = { 
        fullyQualifyGlobalConstantsAndFunctions = true,
        insertUseDeclaration = true,           -- Importa automáticamente las clases
        maxItems = 100,
      },
      -- Activar mensajes de servidor visibles para indexación
      trace = { 
        server = "messages",
      }
    }
  }
})

-- Configuración existente
vim.g.laravel_cache = 1
vim.api.nvim_set_keymap('n', '<leader>pl', ':Laravel<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>ps', ':!symfony server:start<CR>', { noremap = true, silent = true }) 
vim.api.nvim_set_keymap('n', '<leader>pc', ':!symfony console<CR>', { noremap = true, silent = true }) 

-- Auto-importación con Ctrl+Enter (agregado a la configuración básica)
vim.api.nvim_set_keymap('n', '<C-CR>', ':lua vim.lsp.buf.code_action({ context = { only = { "source.addMissingImports" } } })<CR>', { noremap = true, silent = true })

-- Formateo automático con php-cs-fixer antes de guardar (mantenido de la config original)
vim.cmd [[autocmd BufWritePre *.php lua vim.lsp.buf.format()]]

-- Comando para reiniciar manualmente la indexación de PHP
vim.api.nvim_create_user_command("PhpIndexRefresh", function()
  vim.cmd("LspRestart intelephense")
  print("🔄 Reiniciando indexación de PHP...")
end, {})

-- Definir comando para mostrar el estado de indexación
vim.api.nvim_create_user_command("PhpIndexStatus", function()
  local clients = vim.lsp.get_active_clients()
  local found = false
  for _, client in ipairs(clients) do
    if client.name == "intelephense" then
      found = true
      if client.server_capabilities.indexing then
        print("📊 Intelephense: ⏳ Indexando...")
      else
        print("✅ Intelephense: Indexación completa")
      end
      break
    end
  end
  if not found then
    print("❌ Intelephense no está activo")
  end
end, {})

print("✅ Perfil PHP cargado - Auto-importación activada (Ctrl+Enter)")
