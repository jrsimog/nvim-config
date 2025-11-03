-- lua/profiles/elixir.lua - Perfil Elixir simplificado
-- El LSP se gestiona automáticamente por Mason (ver lua/core/lsp.lua)

local M = {}

function M.setup()
    -- El LSP elixirls se configura automáticamente en lua/core/lsp.lua
    -- Aquí solo agregamos configuraciones específicas de Elixir

    -- Configuraciones de editor específicas para archivos Elixir
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "elixir", "eelixir", "heex" },
        callback = function()
            -- Indentación de 2 espacios (estándar Elixir)
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
            vim.opt_local.expandtab = true
            vim.opt_local.updatetime = 300
        end,
    })

    -- Comando para verificar el estado de ElixirLS
    vim.api.nvim_create_user_command("ElixirStatus", function()
        print("🔍 Estado de ElixirLS:")
        print("")

        -- Verificar clientes LSP activos
        local clients = vim.lsp.get_active_clients({ name = "elixirls" })
        if #clients > 0 then
            for _, client in ipairs(clients) do
                print("  ✅ Cliente " .. client.id .. ": " .. (client.is_stopped() and "❌ Detenido" or "✅ Activo"))
                print("  • Root dir: " .. (client.config.root_dir or "❌ No detectado"))
                print("  • Capacidades:")
                print("    - Autocompletado: " .. (client.server_capabilities.completionProvider and "✅" or "❌"))
                print("    - Go to definition: " .. (client.server_capabilities.definitionProvider and "✅" or "❌"))
                print("    - Hover: " .. (client.server_capabilities.hoverProvider and "✅" or "❌"))
            end
        else
            print("  ❌ No hay clientes ElixirLS activos")
            print("  💡 Asegúrate de que Mason instaló elixir-ls: :Mason")
        end

        print("")

        -- Verificar proyecto Mix
        local cwd = vim.fn.getcwd()
        local mix_exs = cwd .. "/mix.exs"
        if vim.fn.filereadable(mix_exs) == 1 then
            print("  ✅ Proyecto Mix encontrado: " .. mix_exs)

            -- Verificar si está compilado
            local build_dir = cwd .. "/_build"
            if vim.fn.isdirectory(build_dir) == 1 then
                print("  ✅ Proyecto compilado (_build existe)")
            else
                print("  ⚠️  Proyecto no compilado")
                print("  💡 Ejecuta: :MixCompile o :!mix compile")
            end
        else
            print("  ⚠️  No se encontró mix.exs en: " .. cwd)
            print("  💡 Asegúrate de abrir Neovim desde la raíz del proyecto")
        end

        print("")
        local has_cmp = pcall(require, "cmp")
        print("  • nvim-cmp: " .. (has_cmp and "✅ Instalado" or "❌ No instalado"))
    end, { desc = "Show ElixirLS status" })

    -- Comandos útiles para proyectos Elixir/Phoenix
    vim.api.nvim_create_user_command("MixCompile", function()
        vim.cmd("!mix compile")
        -- Reiniciar LSP después de compilar
        vim.defer_fn(function()
            vim.cmd("LspRestart")
            print("✅ Proyecto compilado. LSP reiniciado.")
        end, 1000)
    end, { desc = "Compile project and restart LSP" })

    vim.api.nvim_create_user_command("MixTest", function()
        vim.cmd("!mix test")
    end, { desc = "Run mix test" })

    vim.api.nvim_create_user_command("MixFormat", function()
        vim.cmd("!mix format")
    end, { desc = "Run mix format on project" })

    vim.api.nvim_create_user_command("MixDeps", function()
        vim.cmd("!mix deps.get")
    end, { desc = "Get mix dependencies" })

    vim.api.nvim_create_user_command("MixClean", function()
        vim.cmd("!mix clean")
        print("🧹 Build artifacts cleaned")
    end, { desc = "Clean build artifacts" })

    vim.api.nvim_create_user_command("PhoenixServer", function()
        vim.cmd("terminal mix phx.server")
    end, { desc = "Start Phoenix server" })

    vim.api.nvim_create_user_command("IexStart", function()
        vim.cmd("terminal iex -S mix")
    end, { desc = "Start IEx session" })

    -- Atajos de teclado específicos para Elixir
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "elixir", "eelixir", "heex" },
        callback = function(args)
            local bufnr = args.buf

            -- Mix commands
            vim.keymap.set("n", "<leader>mt", ":MixTest<CR>", { buffer = bufnr, desc = "Run mix test" })
            vim.keymap.set("n", "<leader>mf", ":MixFormat<CR>", { buffer = bufnr, desc = "Run mix format" })
            vim.keymap.set("n", "<leader>md", ":MixDeps<CR>", { buffer = bufnr, desc = "Get mix deps" })

            -- Phoenix commands
            vim.keymap.set("n", "<leader>ps", ":PhoenixServer<CR>", { buffer = bufnr, desc = "Start Phoenix server" })
            vim.keymap.set("n", "<leader>pi", ":IexStart<CR>", { buffer = bufnr, desc = "Start IEx" })
        end,
    })
end

return M
