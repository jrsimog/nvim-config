-- lua/profiles/php.lua - Perfil PHP con Symfony y Laravel

local M = {}

function M.setup()
    -- Evitar configurar múltiples veces
    if vim.g.php_profile_loaded then
        return
    end
    vim.g.php_profile_loaded = true

    print("🐘 Cargando perfil PHP con Symfony y Laravel")

    -- Configurar Intelephense específicamente para este perfil

    -- Obtener capabilities del sistema LSP base si existe
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Configurar position encoding para evitar warnings
    capabilities.general = capabilities.general or {}
    capabilities.general.positionEncodings = { "utf-16", "utf-8" }

    -- Intentar obtener capabilities de nvim-cmp si está disponible
    local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if cmp_ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- Verificar que intelephense esté disponible
    local intelephense_cmd = vim.fn.exepath("intelephense")
    if intelephense_cmd == "" then
        vim.notify("❌ Intelephense no encontrado en PATH", vim.log.levels.ERROR)
        return
    end
    print("✅ Intelephense encontrado en: " .. intelephense_cmd)
    
    -- Crear grupo de autocmd único para evitar duplicaciones
    local augroup = vim.api.nvim_create_augroup("IntelephenseSetup", { clear = true })

    -- Configurar LSP usando vim.lsp.start (más simple y confiable)
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "php",
        callback = function(ev)
            local bufnr = ev.buf

            -- Verificar si ya hay un cliente LSP activo globalmente (no solo en este buffer)
            local all_clients = vim.lsp.get_clients({ name = "intelephense" })
            if #all_clients > 0 then
                print("🐘 Intelephense ya está ejecutándose (conectando a buffer " .. bufnr .. ")")
                -- Solo conectar al buffer existente
                for _, client in ipairs(all_clients) do
                    vim.lsp.buf_attach_client(bufnr, client.id)
                end
                return
            end

            print("🚀 Iniciando Intelephense para buffer " .. bufnr)

            vim.lsp.start({
                    name = "intelephense",
                    cmd = { "intelephense", "--stdio" },
                    root_dir = function(fname)
                        return vim.fs.root(fname, { "composer.json", ".git", "index.php" }) or vim.fn.getcwd()
                    end,
                    capabilities = capabilities,
                    settings = {
                        intelephense = {
                            files = {
                                maxSize = 5000000,
                                associations = { "*.php", "*.phtml" },
                                exclude = {
                                    "**/node_modules/**",
                                    "**/.git/**",
                                    "**/var/cache/**",
                                    "**/var/logs/**",
                                    "**/var/sessions/**",
                                    "**/app/cache/**",
                                    "**/app/logs/**"
                                }
                            },
                            environment = {
                                includePaths = {
                                    "vendor",
                                    "src",
                                    "app"
                                },
                                phpVersion = "7.4"
                            },
                            diagnostics = {
                                enable = true,
                                run = "onSave",
                                embeddedLanguages = false
                            },
                            completion = {
                                fullyQualifyGlobalConstantsAndFunctions = true,
                                insertUseDeclaration = true,
                                maxItems = 100
                            },
                            format = {
                                enable = true
                            },
                            phpdoc = {
                                returnVoid = false,
                                textFormat = "snippet"
                            },
                            -- Configuración específica para proyectos Symfony
                            stubs = {
                                "bcmath",
                                "bz2",
                                "calendar",
                                "Core",
                                "curl",
                                "date",
                                "dba",
                                "dom",
                                "enchant",
                                "fileinfo",
                                "filter",
                                "ftp",
                                "gd",
                                "gettext",
                                "hash",
                                "iconv",
                                "imap",
                                "intl",
                                "json",
                                "ldap",
                                "libxml",
                                "mbstring",
                                "mcrypt",
                                "mysql",
                                "mysqli",
                                "password",
                                "pcntl",
                                "pcre",
                                "PDO",
                                "pdo_mysql",
                                "Phar",
                                "readline",
                                "recode",
                                "Reflection",
                                "regex",
                                "session",
                                "SimpleXML",
                                "soap",
                                "sockets",
                                "sodium",
                                "SPL",
                                "standard",
                                "superglobals",
                                "sysvsem",
                                "sysvshm",
                                "tokenizer",
                                "xml",
                                "xdebug",
                                "xmlreader",
                                "xmlwriter",
                                "yaml",
                                "zip",
                                "zlib",
                                "symfony"
                            },
                            trace = {
                                server = "messages"
                            }
                        },
                    },
                    on_attach = function(client, buf)
                        print("🎉 Intelephense conectado exitosamente a buffer " .. buf)
                        print("📚 Indexando proyecto PHP... (esto puede tomar unos segundos)")

                        -- Configurar keymaps básicos
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = buf, desc = "Rename" })
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf, desc = "Hover info" })

                        -- Go to definition con mejor feedback
                        vim.keymap.set('n', 'gd', function()
                            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

                            vim.lsp.buf_request(buf, 'textDocument/definition', params, function(err, result, ctx)
                                if err then
                                    vim.notify("❌ Error al buscar definición: " .. err.message, vim.log.levels.ERROR)
                                    return
                                end

                                if not result or vim.tbl_isempty(result) then
                                    -- Verificar si el servidor está listo
                                    if not client.server_capabilities.definitionProvider then
                                        vim.notify("⏳ Intelephense aún está indexando. Espera unos segundos...", vim.log.levels.WARN)
                                    else
                                        vim.notify("🔍 No se encontró definición para el símbolo bajo el cursor", vim.log.levels.INFO)
                                    end
                                    return
                                end

                                -- Usar el handler por defecto si hay resultado
                                vim.lsp.handlers['textDocument/definition'](err, result, ctx)
                            end)
                        end, { buffer = buf, desc = "Go to definition (enhanced)" })

                        -- Verificar estado de indexación y proyecto
                        local check_indexing
                        check_indexing = function()
                            vim.defer_fn(function()
                                if client.server_capabilities.definitionProvider then
                                    print("✅ Indexación completa - Go to definition disponible")

                                    -- Verificar problemas comunes del proyecto
                                    vim.defer_fn(function()
                                        -- client.config.root_dir es una función, necesitamos ejecutarla
                                        local root_dir_func = client.config.root_dir
                                        local current_file = vim.api.nvim_buf_get_name(buf)
                                        local root_dir = root_dir_func and root_dir_func(current_file)

                                        if root_dir then
                                            local composer_json = root_dir .. "/composer.json"
                                            local vendor_autoload = root_dir .. "/vendor/autoload.php"

                                            if vim.fn.filereadable(composer_json) == 1 then
                                                if vim.fn.filereadable(vendor_autoload) == 0 then
                                                    vim.notify("⚠️  vendor/autoload.php no encontrado. Ejecuta: composer install", vim.log.levels.WARN)
                                                end
                                            else
                                                vim.notify("⚠️  composer.json no encontrado en el root del proyecto", vim.log.levels.WARN)
                                            end
                                        end
                                    end, 3000) -- Verificar después de 3 segundos
                                else
                                    print("📚 Aún indexando...")
                                    check_indexing() -- Seguir verificando
                                end
                            end, 2000) -- Verificar cada 2 segundos
                        end
                        check_indexing()
                    end,
                })
        end,
    })

    -- Comando para debug y reinicialización
    vim.api.nvim_create_user_command("DebugPhpLsp", function()
        print("🐛 Debug PHP LSP:")
        print("Intelephense path: " .. intelephense_cmd)

        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local current_file = vim.api.nvim_buf_get_name(bufnr)

        print("📄 Archivo actual: " .. current_file)
        print("📁 Directorio de trabajo: " .. vim.fn.getcwd())

        print("Clientes LSP activos en buffer " .. bufnr .. ":")
        if #clients == 0 then
            print("  ❌ No hay clientes LSP activos")
        else
            for _, client in ipairs(clients) do
                print("  ✅ " .. client.name .. " (ID: " .. client.id .. ")")
                if client.name == "intelephense" then
                    print("    Definiciones: " .. (client.server_capabilities.definitionProvider and "✅" or "❌"))
                    print("    Hover: " .. (client.server_capabilities.hoverProvider and "✅" or "❌"))
                    print("    Completions: " .. (client.server_capabilities.completionProvider and "✅" or "❌"))
                    print("    References: " .. (client.server_capabilities.referencesProvider and "✅" or "❌"))
                    print("    Root dir: " .. (client.config.root_dir or "❌ No configurado"))
                    print("    Offset encoding: " .. (client.offset_encoding or "utf-16"))

                    -- Información adicional sobre el workspace
                    if client.config.root_dir then
                        local composer_json = client.config.root_dir .. "/composer.json"
                        local vendor_dir = client.config.root_dir .. "/vendor"
                        print("    composer.json: " .. (vim.fn.filereadable(composer_json) == 1 and "✅" or "❌"))
                        print("    vendor/: " .. (vim.fn.isdirectory(vendor_dir) == 1 and "✅" or "❌"))

                        if vim.fn.filereadable(composer_json) == 1 then
                            local composer_content = vim.fn.readfile(composer_json)
                            local composer_str = table.concat(composer_content, "")
                            if composer_str:match('"autoload"') then
                                print("    autoload configurado: ✅")
                            else
                                print("    autoload configurado: ❌")
                            end
                        end
                    end
                end
            end
        end

        -- Información del proyecto
        local root_dir = vim.fs.root(current_file, { "composer.json", ".git", "index.php" })
        print("📁 Root directory detectado: " .. (root_dir or "❌ No encontrado"))

        -- Test de posición actual
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        local word_under_cursor = vim.fn.expand("<cword>")
        print("🎯 Posición cursor: línea " .. row .. ", columna " .. col)
        print("🔤 Palabra bajo cursor: '" .. word_under_cursor .. "'")
        print("📝 Línea actual: " .. line:sub(1, 80) .. (line:len() > 80 and "..." or ""))

        -- Prueba manual de definición
        print("\n🧪 Ejecutando prueba de definición...")
        local clients_for_test = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
        if #clients_for_test > 0 then
            local client = clients_for_test[1]
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
            print("📋 Parámetros LSP: uri=" .. params.textDocument.uri)
            print("    posición: línea " .. params.position.line .. ", carácter " .. params.position.character)
        end
    end, {})

    -- Comando para reiniciar LSP manualmente
    vim.api.nvim_create_user_command("RestartPhpLsp", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })

        if #clients > 0 then
            print("🔄 Deteniendo cliente Intelephense...")
            for _, client in ipairs(clients) do
                client.stop()
            end
            vim.defer_fn(function()
                print("🚀 Reiniciando Intelephense...")
                vim.cmd("edit") -- Recargar buffer para activar autocmd
            end, 1000)
        else
            print("❌ No hay cliente Intelephense activo para reiniciar")
        end
    end, {})

    -- Configuración específica de PHP
    vim.g.laravel_cache = 1

    -- Keymaps específicos de PHP (solo los que no están en keymaps.lua)
    vim.api.nvim_set_keymap("n", "<leader>pl", ":Laravel<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>ps", ":!symfony server:start<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>pc", ":!symfony console<CR>", { noremap = true, silent = true })

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
