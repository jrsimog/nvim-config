-- lua/profiles/php.lua - Perfil PHP simplificado
-- El LSP se gestiona automáticamente por Mason (ver lua/core/lsp.lua)

local M = {}

function M.setup()
    -- El LSP intelephense se configura automáticamente en lua/core/lsp.lua
    -- Aquí solo agregamos configuraciones específicas de PHP

    -- Configuraciones de editor específicas para archivos PHP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "php" },
        callback = function()
            -- Indentación de 4 espacios (estándar PHP/PSR)
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true
        end,
    })

    -- Configuración específica de PHP
    vim.g.laravel_cache = 1

    -- Comandos útiles para PHP
    vim.api.nvim_create_user_command("PhpIndexRefresh", function()
        vim.cmd("LspRestart intelephense")
        print("🔄 Reiniciando indexación de PHP...")
    end, { desc = "Refresh PHP index by restarting Intelephense" })

    vim.api.nvim_create_user_command("PhpImport", function()
        vim.lsp.buf.code_action({
            context = {
                only = { "source.addMissingImports" },
            },
        })
    end, { desc = "Import missing PHP classes" })

    -- Atajos de teclado específicos para PHP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function(args)
            local bufnr = args.buf

            -- Comando para importar clases automáticamente
            vim.api.nvim_buf_create_user_command(bufnr, "PhpImportClass", function()
                vim.lsp.buf.code_action({
                    context = {
                        only = { "source.addMissingImports" },
                    },
                })
            end, { desc = "Import missing PHP class" })

            -- Atajos para importación automática
            vim.keymap.set("n", "<C-CR>", ":PhpImportClass<CR>", {
                buffer = bufnr,
                noremap = true,
                silent = true,
                desc = "Import PHP class"
            })

            vim.keymap.set("i", "<C-CR>", "<Esc>:PhpImportClass<CR>a", {
                buffer = bufnr,
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
        end,
    })

    -- Comandos para Laravel
    vim.api.nvim_create_user_command("LaravelArtisan", function(opts)
        vim.cmd("!php artisan " .. opts.args)
    end, { nargs = "*", desc = "Run Laravel Artisan command" })

    vim.api.nvim_create_user_command("LaravelServe", function()
        vim.cmd("terminal php artisan serve")
    end, { desc = "Start Laravel development server" })

    -- Comandos para Symfony
    vim.api.nvim_create_user_command("SymfonyConsole", function(opts)
        vim.cmd("!php bin/console " .. opts.args)
    end, { nargs = "*", desc = "Run Symfony console command" })

    vim.api.nvim_create_user_command("SymfonyServe", function()
        vim.cmd("terminal symfony serve")
    end, { desc = "Start Symfony development server" })

    -- Comandos para Composer
    vim.api.nvim_create_user_command("ComposerInstall", function()
        vim.cmd("!composer install")
    end, { desc = "Run composer install" })

    vim.api.nvim_create_user_command("ComposerUpdate", function()
        vim.cmd("!composer update")
    end, { desc = "Run composer update" })

    vim.api.nvim_create_user_command("ComposerRequire", function(opts)
        vim.cmd("!composer require " .. opts.args)
    end, { nargs = 1, desc = "Run composer require" })
end

return M
