-- lua/profiles/sh.lua - Shell/Zsh/Bash profile

local M = {}

function M.setup()
    -- print("🔧 Cargando perfil Shell/Zsh...")

    -- Verificar si lspconfig está disponible
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if not lspconfig_ok then
        vim.notify("⚠️ lspconfig no disponible", vim.log.levels.WARN)
        return
    end

    -- Note: bashls (bash-language-server) is managed by Mason and configured in lua/core/lsp.lua
    -- We just set up shell-specific keymaps when LSP attaches

    -- Set up keymaps when LSP attaches to shell buffers
    vim.api.nvim_create_autocmd("LspAttach", {
        pattern = { "*.sh", "*.bash", "*.zsh", ".bashrc", ".zshrc", ".bash_profile", ".bash_aliases" },
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            -- Only set keymaps for bashls
            if client and client.name == "bashls" then
                local opts = { noremap = true, silent = true, buffer = bufnr }

                -- Execute current script
                vim.keymap.set("n", "<leader>sx", function()
                    local filepath = vim.fn.expand("%:p")
                    local filetype = vim.bo.filetype
                    local shell = "bash"
                    if filetype == "zsh" or filepath:match("%.zshrc$") then
                        shell = "zsh"
                    end
                    vim.cmd("vsplit | terminal " .. shell .. " " .. vim.fn.shellescape(filepath))
                end, vim.tbl_extend("force", opts, { desc = "Execute shell script" }))

                -- Source current file
                vim.keymap.set("n", "<leader>ss", function()
                    local filepath = vim.fn.expand("%:p")
                    local filetype = vim.bo.filetype
                    local shell = "bash"
                    if filetype == "zsh" or filepath:match("%.zshrc$") then
                        shell = "zsh"
                    end
                    vim.cmd("!" .. shell .. " " .. vim.fn.shellescape(filepath))
                end, vim.tbl_extend("force", opts, { desc = "Source shell script" }))

                -- ShellCheck analysis
                vim.keymap.set("n", "<leader>sc", function()
                    local filepath = vim.fn.expand("%:p")
                    vim.cmd("!shellcheck -x " .. vim.fn.shellescape(filepath))
                end, vim.tbl_extend("force", opts, { desc = "Run ShellCheck" }))

                -- Make file executable
                vim.keymap.set("n", "<leader>sm", function()
                    local filepath = vim.fn.expand("%:p")
                    vim.fn.system("chmod +x " .. vim.fn.shellescape(filepath))
                    vim.notify("Made " .. filepath .. " executable", vim.log.levels.INFO)
                end, vim.tbl_extend("force", opts, { desc = "Make script executable" }))

                -- Insert shebang
                vim.keymap.set("n", "<leader>sb", function()
                    local filetype = vim.bo.filetype
                    local shebang = "#!/usr/bin/env bash"
                    if filetype == "zsh" then
                        shebang = "#!/usr/bin/env zsh"
                    end
                    vim.api.nvim_buf_set_lines(0, 0, 0, false, { shebang })
                    vim.notify("Added shebang: " .. shebang, vim.log.levels.INFO)
                end, vim.tbl_extend("force", opts, { desc = "Insert shebang" }))
            end
        end,
    })

    -- Shell-specific buffer settings
    vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
        pattern = { "*.sh", "*.bash", "*.zsh", ".bashrc", ".zshrc", ".bash_profile", ".bash_aliases" },
        callback = function()
            -- Set proper filetype for rc files
            local filename = vim.fn.expand("%:t")
            if filename:match("zshrc") or filename:match("%.zsh$") then
                vim.bo.filetype = "zsh"
            elseif filename:match("bashrc") or filename:match("bash_") or filename:match("%.bash$") then
                vim.bo.filetype = "bash"
            end

            -- Shell formatting options
            vim.bo.expandtab = true
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
            vim.bo.textwidth = 100

            -- Enable automatic shebang detection
            local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
            if #lines > 0 and lines[1]:match("^#!.*zsh") then
                vim.bo.filetype = "zsh"
            elseif #lines > 0 and lines[1]:match("^#!.*bash") then
                vim.bo.filetype = "bash"
            end
        end,
    })

    -- Auto-format on save (using shfmt if available)
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.sh", "*.bash", "*.zsh" },
        callback = function()
            -- Try to format with LSP first
            local format_ok, _ = pcall(function()
                vim.lsp.buf.format({ timeout_ms = 2000 })
            end)

            -- If LSP formatting failed and shfmt is available, use it
            if not format_ok then
                local shfmt_available = vim.fn.executable("shfmt") == 1
                if shfmt_available then
                    local filepath = vim.fn.expand("%:p")
                    vim.fn.system("shfmt -i 2 -w " .. vim.fn.shellescape(filepath))
                    vim.cmd("edit!") -- Reload the file
                end
            end
        end,
    })

    -- Syntax highlighting enhancements
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sh", "bash", "zsh" },
        callback = function()
            -- Enable syntax folding
            vim.wo.foldmethod = "syntax"
            vim.wo.foldlevel = 99 -- Start with all folds open

            -- Highlight important patterns
            vim.fn.matchadd("Error", "\\<TODO\\>")
            vim.fn.matchadd("Error", "\\<FIXME\\>")
            vim.fn.matchadd("Todo", "\\<NOTE\\>")
        end,
    })

    -- print("✅ 🔧 Shell profile loaded")
end

return M
