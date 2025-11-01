-- lua/profiles/php.lua - Perfil PHP modernizado con Mason

local M = {}

function M.setup()
    -- print("🐘 Cargando perfil PHP con Symfony y Laravel...")

    local lspconfig = require("lspconfig")

    -- Verificar si Intelephense ya fue configurado por otro perfil
    if _G.is_lsp_configured_by_profile("intelephense") then
        -- print("⏭️ Intelephense ya configurado por otro perfil")
        return
    end

    -- Obtener configuración base del sistema LSP
    local base_config = _G.get_lsp_config()

    -- Configuración específica de Intelephense
    local php_config = vim.tbl_deep_extend("force", base_config, {
        -- Mason maneja la instalación automáticamente
        settings = {
            intelephense = {
                files = {
                    maxSize = 5000000,
                    associations = { "*.php", "*.html", "*.css", "*.php", "*.php.html", "*.php.css" },
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
                trace = { server = "messages" },
                environment = {
                    includePaths = { "vendor/" },
                },
            },
        },
        on_attach = function(client, bufnr)
            -- Llamar al on_attach base
            base_config.on_attach(client, bufnr)

            -- Configuraciones específicas de PHP
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

            -- Comando para importar clases automáticamente
            vim.api.nvim_buf_create_user_command(bufnr, "PhpImportClass", function()
                vim.lsp.buf.code_action({
                    context = {
                        only = { "source.addMissingImports" },
                    },
                })
            end, { desc = "Import missing PHP class" })

            -- Atajos para importación automática
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-CR>", ":PhpImportClass<CR>", {
                noremap = true,
                silent = true,
                desc = "Import PHP class"
            })
            vim.api.nvim_buf_set_keymap(bufnr, "i", "<C-CR>", "<Esc>:PhpImportClass<CR>a", {
                noremap = true,
                silent = true,
                desc = "Import PHP class (insert mode)"
            })

            -- Importación automática al completar
            vim.api.nvim_create_autocmd("CompleteDone", {
                buffer = bufnr,
                callback = function()
                    local completed_item = vim.v.completed_item
                    if completed_item and completed_item.user_data and
                       completed_item.user_data.lspitem and
                       completed_item.user_data.lspitem.kind == 7 then
                        vim.defer_fn(function()
                            vim.cmd("PhpImportClass")
                        end, 100)
                    end
                end,
            })

            -- print("🐘 Intelephense configurado para buffer " .. bufnr)
        end,
    })

    -- Configurar Intelephense usando la nueva API de Neovim 0.11+
    if vim.lsp.config then
        -- Usar vim.lsp.config() para Neovim 0.11+
        vim.lsp.config("intelephense", php_config)
        -- Habilitar manualmente el LSP para archivos PHP
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "php",
            callback = function()
                vim.lsp.enable("intelephense")
            end,
        })
    else
        -- Fallback para versiones anteriores
        lspconfig.intelephense.setup(php_config)
    end

    -- Registrar que este perfil configuró Intelephense
    _G.register_profile_lsp("intelephense", "php")

    -- Configuración específica de PHP
    vim.g.laravel_cache = 1

    -- Nota: Los keymaps de Laravel/Symfony están en core/keymaps.lua
    -- <leader>pl → Laravel
    -- <leader>sys → Symfony server
    -- <leader>syc → Symfony console

    -- Formateo automático con php-cs-fixer antes de guardar
    vim.cmd([[
      augroup PhpFormat
        autocmd!
        autocmd BufWritePre *.php silent! execute '!php-cs-fixer fix % --quiet'
        autocmd BufWritePost *.php edit!
      augroup END
    ]])

    -- Comandos útiles para PHP
    vim.api.nvim_create_user_command("PhpIndexRefresh", function()
        vim.cmd("LspRestart intelephense")
        print("🔄 Reiniciando indexación de PHP...")
    end, {})

    vim.api.nvim_create_user_command("PhpImport", function()
        vim.lsp.buf.code_action({
            context = {
                only = { "source.addMissingImports" },
            },
        })
    end, {})

    -- Configuraciones adicionales específicas para PHP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "php" },
        callback = function()
            -- Configurar indentación para archivos PHP
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true
        end,
    })

    -- print("✅ Perfil PHP cargado con soporte de importación automática")
end

return M
