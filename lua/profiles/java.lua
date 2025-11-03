-- lua/profiles/java.lua - Perfil Java simplificado
-- El LSP se gestiona automáticamente por Mason (ver lua/core/lsp.lua)

local M = {}

function M.setup()
    -- El LSP jdtls se configura automáticamente en lua/core/lsp.lua
    -- Aquí solo agregamos configuraciones específicas de Java

    -- Configuraciones de editor específicas para archivos Java
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function()
            -- Indentación de 4 espacios (estándar Java)
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true

            -- Longitud de línea para Java
            vim.opt_local.textwidth = 120
            vim.opt_local.colorcolumn = "120"
        end,
    })

    -- Atajos de teclado específicos para Java
    vim.keymap.set("n", "<leader>jc", ":JdtCompile<CR>", { noremap = true, silent = true, desc = "Compile Java file" })
    vim.keymap.set("n", "<leader>jr", ":JdtUpdateConfig<CR>", { noremap = true, silent = true, desc = "Update Java config" })
    vim.keymap.set("n", "<leader>ji", ":JdtOrganizeImports<CR>", { noremap = true, silent = true, desc = "Organize Java imports" })
    vim.keymap.set("n", "<leader>jt", ":JdtTestClass<CR>", { noremap = true, silent = true, desc = "Run Java test class" })
    vim.keymap.set("n", "<leader>jm", ":!mvn compile<CR>", { noremap = true, silent = true, desc = "Maven compile" })
    vim.keymap.set("n", "<leader>jr", ":!mvn test<CR>", { noremap = true, silent = true, desc = "Maven test" })

    -- Comandos útiles para Java
    vim.api.nvim_create_user_command("JavaCompile", function()
        local file = vim.fn.expand("%:t:r")
        vim.cmd("!javac " .. vim.fn.expand("%") .. " && java " .. file)
    end, { desc = "Compile and run current Java file" })

    vim.api.nvim_create_user_command("MavenClean", function()
        vim.cmd("!mvn clean")
    end, { desc = "Run mvn clean" })

    vim.api.nvim_create_user_command("MavenPackage", function()
        vim.cmd("!mvn package")
    end, { desc = "Run mvn package" })

    vim.api.nvim_create_user_command("MavenInstall", function()
        vim.cmd("!mvn install")
    end, { desc = "Run mvn install" })
end

return M
