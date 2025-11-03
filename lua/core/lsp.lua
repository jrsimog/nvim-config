-- lua/core/lsp.lua
-- Configuración centralizada LSP con Mason como gestor único

-- ========== Global LSP Profile Management ==========
-- Track which LSPs have been configured by profiles to avoid conflicts
_G.profile_configured_lsps = _G.profile_configured_lsps or {}

-- Check if an LSP has already been configured by a profile
_G.is_lsp_configured_by_profile = function(lsp_name)
  return _G.profile_configured_lsps[lsp_name] ~= nil
end

-- Register that a profile has configured an LSP
_G.register_profile_lsp = function(lsp_name, profile_name)
  _G.profile_configured_lsps[lsp_name] = profile_name
end

-- ========== LSP on_attach Configuration ==========
-- Esta función se ejecuta cuando un LSP se adjunta a un buffer
local on_attach = function(client, bufnr)
  -- Debug: confirmar que on_attach se ejecuta
  print("🔧 LSP on_attach: " .. client.name .. " en buffer " .. bufnr)

  -- Habilitar autocompletado con <C-x><C-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Atajos de teclado para funciones LSP
  -- Usar vim.keymap.del primero para asegurarnos de sobrescribir cualquier mapeo previo





  -- Habilitar el formateo si el LSP lo soporta
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, { clear = true }),
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
      desc = "Format file before saving",
    })
  end
end

-- Get the base LSP configuration (on_attach and capabilities)
-- This function is used by profiles to get consistent LSP configuration
_G.get_lsp_config = function()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  return {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- ========== Custom LSP Handler for Definition ==========
-- Override the default handler to add logging and custom behavior
vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
  print("🎯 Handler textDocument/definition ejecutado")

  if err then
    print("❌ Error en textDocument/definition: " .. vim.inspect(err))
    vim.notify("Error en go to definition: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if not result or vim.tbl_isempty(result) then
    print("⚠️  textDocument/definition: Result es nil o vacío")
    vim.notify("No se encontró definición en ElixirLS", vim.log.levels.WARN)
    return
  end

  print("✅ textDocument/definition: Definición encontrada!")
  print("   Tipo de resultado: " .. type(result))
  print("   Contenido: " .. vim.inspect(result))

  -- Si result es una tabla con un solo elemento, extraerlo
  local location = result
  if type(result) == "table" and #result == 1 then
    location = result[1]
  end

  -- Usar vim.lsp.util.jump_to_location para navegar
  if location.uri or location.targetUri then
    vim.lsp.util.jump_to_location(location, "utf-8")
    vim.notify("✅ Navegado a la definición", vim.log.levels.INFO)
  else
    vim.notify("⚠️  Definición encontrada pero formato inesperado", vim.log.levels.WARN)
  end
end



-- ========== Diagnostic Icons Configuration ==========
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ========== Mason LSP Setup ==========
-- Verificar que los módulos necesarios estén disponibles
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  vim.notify("Mason not available yet", vim.log.levels.WARN)
  return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
  -- Silently return if mason-lspconfig is not available
  -- This can happen during initial plugin installation
  return
end

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  return
end

-- Capacidades del cliente (para nvim-cmp)
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_ok then
  return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

-- ========== Configuraciones específicas por LSP ==========
-- Estas configuraciones se aplicarán automáticamente cuando Mason instale el LSP

local server_configs = {
  -- Lua Language Server
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim", "use" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  -- TypeScript/JavaScript
  ts_ls = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- Python (Pyright)
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "basic",
        },
      },
    },
  },

  -- PHP (Intelephense)
  intelephense = {
    settings = {
      intelephense = {
        files = {
          maxSize = 5000000,
          associations = { "*.php", "*.html", "*.css", "*.php.html", "*.php.css" },
        },
        diagnostics = {
          enable = true,
          run = "onType",
        },
        completion = {
          fullyQualifyGlobalConstantsAndFunctions = true,
          insertUseDeclaration = true,
          maxItems = 100,
        },
        format = {
          enable = true,
        },
        environment = {
          includePaths = { "vendor/" },
        },
      },
    },
  },

  -- Elixir (ElixirLS)
  elixirls = {
    cmd = (function()
      local home = vim.fn.expand("~")
      local els_path = vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh"

      -- Construir el PATH con asdf shims para que ElixirLS encuentre Elixir y Erlang
      local asdf_shims = home .. "/.asdf/shims"
      local asdf_bin = home .. "/.asdf/bin"

      return {
        "bash", "-c",
        string.format(
          "export PATH=%s:%s:$PATH && %s",
          asdf_shims,
          asdf_bin,
          els_path
        )
      }
    end)(),
    root_dir = function(fname)
      local util = require("lspconfig.util")
      -- Buscar mix.exs en el directorio actual o superior
      return util.root_pattern("mix.exs", ".git")(fname) or util.path.dirname(fname)
    end,
    settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = true, -- Permite navegar a definiciones en dependencias
        suggestSpecs = true,
        signatureAfterComplete = true,
        mixEnv = "dev",
        enableTestLenses = false,
        autoInsertRequiredAlias = true,
        signatureHelp = { enabled = true },
      },
    },
  },

  -- Java (JDTLS)
  jdtls = {
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },
  },

  -- HTML
  html = {
    settings = {
      html = {
        format = {
          templating = true,
          wrapLineLength = 120,
          wrapAttributes = "auto",
        },
        hover = {
          documentation = true,
          references = true,
        },
      },
    },
  },

  -- CSS
  cssls = {
    settings = {
      css = {
        validate = true,
        lint = {
          unknownAtRules = "ignore",
        },
      },
      scss = {
        validate = true,
        lint = {
          unknownAtRules = "ignore",
        },
      },
      less = {
        validate = true,
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
  },

  -- JSON
  jsonls = {
    settings = {
      json = {
        schemas = (function()
          local ok, schemastore = pcall(require, "schemastore")
          if ok then
            return schemastore.json.schemas()
          end
          return {}
        end)(),
        validate = { enable = true },
      },
    },
  },

  -- YAML
  yamlls = {
    settings = {
      yaml = {
        schemas = (function()
          local ok, schemastore = pcall(require, "schemastore")
          if ok then
            return schemastore.yaml.schemas()
          end
          return {}
        end)(),
        validate = true,
        format = {
          enable = true,
        },
      },
    },
  },

  -- Bash
  bashls = {
    settings = {
      bashIde = {
        globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      },
    },
  },
}

-- ========== Mason LSPConfig Setup Handlers ==========
-- Esta configuración garantiza que todos los LSPs instalados por Mason
-- se configuren automáticamente con las opciones correctas

-- Solo configurar handlers si mason_lspconfig está disponible
if mason_lspconfig and type(mason_lspconfig.setup_handlers) == "function" then
  mason_lspconfig.setup_handlers({
    -- Handler por defecto para todos los servidores
    function(server_name)
      -- Saltar servidores que ya fueron configurados por un perfil
      if _G.is_lsp_configured_by_profile(server_name) then
        return
      end

      -- Obtener configuración específica del servidor (si existe)
      local server_config = server_configs[server_name] or {}

      -- Combinar con configuración base
      local config = vim.tbl_deep_extend("force", {
        on_attach = on_attach,
        capabilities = capabilities,
      }, server_config)

      -- Configurar el servidor
      lspconfig[server_name].setup(config)
    end,

    -- Handlers específicos para servidores que necesitan configuración especial
    -- (Los perfiles pueden sobreescribir estos si es necesario)
  })
end

-- ========== Comandos útiles para LSP ==========

-- Comando para verificar qué LSP está activo en el buffer actual
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("❌ No hay clientes LSP activos en este buffer")
    return
  end

  print("📋 Clientes LSP activos:")
  for _, client in ipairs(clients) do
    print("  • " .. client.name .. " (id: " .. client.id .. ")")
  end
end, { desc = "Show active LSP clients in current buffer" })

-- Comando para reiniciar todos los LSPs del buffer actual
vim.api.nvim_create_user_command("LspRestart", function()
  vim.cmd("LspStop")
  vim.defer_fn(function()
    vim.cmd("LspStart")
  end, 100)
end, { desc = "Restart all LSP clients in current buffer" })

-- Comando para verificar capacidades del LSP
vim.api.nvim_create_user_command("LspCapabilities", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("❌ No hay clientes LSP activos")
    return
  end

  for _, client in ipairs(clients) do
    print("📋 Capacidades de " .. client.name .. ":")
    print("  • Hover: " .. (client.server_capabilities.hoverProvider and "✅" or "❌"))
    print("  • Completion: " .. (client.server_capabilities.completionProvider and "✅" or "❌"))
    print("  • Definition: " .. (client.server_capabilities.definitionProvider and "✅" or "❌"))
    print("  • References: " .. (client.server_capabilities.referencesProvider and "✅" or "❌"))
    print("  • Formatting: " .. (client.server_capabilities.documentFormattingProvider and "✅" or "❌"))
    print("  • Rename: " .. (client.server_capabilities.renameProvider and "✅" or "❌"))
  end
end, { desc = "Show LSP server capabilities" })

-- Comando para listar todos los LSPs configurados por perfiles
vim.api.nvim_create_user_command("LspProfileStatus", function()
  print("📋 LSPs configurados por perfiles:")
  local count = 0
  for lsp, profile in pairs(_G.profile_configured_lsps) do
    print("  • " .. lsp .. " → " .. profile)
    count = count + 1
  end
  if count == 0 then
    print("  (ninguno)")
  end
end, { desc = "Show which LSPs are configured by profiles" })
