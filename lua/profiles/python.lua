-- lua/profiles/python.lua - Perfil Python simplificado
-- El LSP se gestiona automáticamente por Mason (ver lua/core/lsp.lua)

local M = {}

function M.setup()
    -- El LSP pyright se configura automáticamente en lua/core/lsp.lua
    -- Aquí solo agregamos configuraciones específicas de Python

    -- Configuraciones de editor específicas para archivos Python
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
            -- Indentación de 4 espacios (PEP 8)
            vim.opt_local.shiftwidth = 4
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true

            -- Longitud de línea para Python (PEP 8: 79, Black: 88)
            vim.opt_local.textwidth = 88
            vim.opt_local.colorcolumn = "88"
        end,
    })

    -- Atajos de teclado específicos para Python
    vim.keymap.set("n", "<leader>pf", ":Black<CR>", { noremap = true, silent = true, desc = "Format with Black" })
    vim.keymap.set("n", "<leader>pr", ":!pytest %<CR>", { noremap = true, silent = true, desc = "Run pytest on current file" })
    vim.keymap.set("n", "<leader>pt", ":!python -m pytest<CR>", { noremap = true, silent = true, desc = "Run all pytest tests" })
    vim.keymap.set("n", "<leader>pi", ":!python %<CR>", { noremap = true, silent = true, desc = "Run current Python file" })

    -- Comandos útiles para Python
    vim.api.nvim_create_user_command("PythonRepl", function()
        vim.cmd("terminal python3")
    end, { desc = "Start Python REPL" })

    vim.api.nvim_create_user_command("PipInstall", function(opts)
        vim.cmd("!pip install " .. opts.args)
    end, { nargs = 1, desc = "Install Python package with pip" })

    vim.api.nvim_create_user_command("PythonVenv", function()
        vim.cmd("!python -m venv venv && source venv/bin/activate")
    end, { desc = "Create and activate Python virtual environment" })

    vim.api.nvim_create_user_command("PythonRequirements", function()
        vim.cmd("!pip install -r requirements.txt")
    end, { desc = "Install requirements from requirements.txt" })
end

return M
