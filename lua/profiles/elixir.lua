-- lua/profiles/elixir.lua - Perfil Elixir modernizado con Mason

local M = {}

function M.setup()
    -- print("⚗️ Cargando perfil Elixir...")

    local lspconfig = require("lspconfig")

    -- Verificar si ElixirLS ya fue configurado por otro perfil
    if _G.is_lsp_configured_by_profile("elixirls") then
        -- print("⏭️ ElixirLS ya configurado por otro perfil")
        return
    end

    -- Obtener configuración base del sistema LSP
    local base_config = _G.get_lsp_config()

    -- Configuración específica de ElixirLS
    local elixir_config = vim.tbl_deep_extend("force", base_config, {
        -- Configurar ElixirLS para evitar conflictos con ASDF
        cmd = {
            "env", "-u", "ASDF_DIR", "-u", "ASDF_DATA_DIR",
            vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/language_server.sh"
        },
        cmd_env = {
            PATH = vim.env.HOME .. "/.asdf/shims:/usr/bin:/bin",
        },
        settings = {
            elixirLS = {
                dialyzerEnabled = false,
                fetchDeps = false,
                suggestSpecs = true,
                signatureAfterComplete = true,
                mixEnv = "dev",
                enableTestLenses = false,
                autoInsertRequiredAlias = true,
                signatureHelp = { enabled = true },
            },
        },
        on_attach = function(client, bufnr)
            -- Llamar al on_attach base
            base_config.on_attach(client, bufnr)

            -- Configuraciones específicas de Elixir
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            client.server_capabilities.documentFormattingProvider = true

            -- Autocompletado inteligente para funciones
            vim.api.nvim_create_autocmd("TextChangedI", {
                buffer = bufnr,
                callback = function()
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    local line = vim.api.nvim_get_current_line()
                    local before_cursor = line:sub(1, col)

                    if before_cursor:match("def[a-z]*$") then
                        vim.schedule(function()
                            local cmp_ok, cmp = pcall(require, "cmp")
                            if cmp_ok then
                                cmp.complete()
                            end
                        end)
                    end
                end,
            })

            -- print("⚗️ ElixirLS configurado para buffer " .. bufnr)
        end,
        root_dir = function(fname)
            -- Buscar mix.exs y crear .tool-versions si no existe
            local root = lspconfig.util.root_pattern("mix.exs", ".git")(fname)
            if root then
                local tool_versions = root .. "/.tool-versions"
                if vim.fn.filereadable(tool_versions) == 0 then
                    vim.fn.writefile({"erlang 27.3.4.3", "elixir 1.18.4-otp-27"}, tool_versions)
                end
            end
            return root
        end,
    })

    -- Configurar ElixirLS usando la nueva API de Neovim 0.11+
    if vim.lsp.config then
        -- Usar vim.lsp.config() para Neovim 0.11+
        vim.lsp.config("elixirls", elixir_config)
        -- Habilitar manualmente el LSP para archivos Elixir
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "elixir", "eelixir", "heex" },
            callback = function()
                vim.lsp.enable("elixirls")
            end,
        })
    else
        -- Fallback para versiones anteriores
        lspconfig.elixirls.setup(elixir_config)
    end

    -- Registrar que este perfil configuró ElixirLS
    _G.register_profile_lsp("elixirls", "elixir")

    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "elixir", "eelixir", "heex" },
        callback = function()
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
            vim.opt_local.expandtab = true
            vim.opt_local.updatetime = 300
        end,
    })

    vim.api.nvim_create_user_command("ElixirStatus", function()
        -- print("🔍 Estado de ElixirLS:")
        -- print("- Comando: " .. (elixir_ls_cmd or "❌ No encontrado"))
        -- print("- Tipo: " .. (elixir_ls_cmd and (elixir_ls_cmd:match("mason") and "Mason" or "Manual") or "N/A"))

        local clients = vim.lsp.get_active_clients({ name = "elixirls" })
        if #clients > 0 then
            for _, client in ipairs(clients) do
                print("- Cliente " .. client.id .. ": " .. (client.is_stopped() and "❌ Detenido" or "✅ Activo"))
                print(
                    "- Capacidades de autocompletado: "
                        .. (client.server_capabilities.completionProvider and "✅ Sí" or "❌ No")
                )
            end
        else
            -- print("- LSP: ❌ No hay clientes activos")
        end

        local has_cmp = pcall(require, "cmp")
        -- print("- nvim-cmp: " .. (has_cmp and "✅ Instalado" or "❌ No instalado"))
    end, {})

    -- print("✅ Perfil Elixir cargado con autocompletado")
end

return M
