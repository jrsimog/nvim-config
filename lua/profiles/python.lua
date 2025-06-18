-- lua/profiles/python.lua
print("🐍 Cargando perfil Python")

vim.g.mapleader = " "

-- Cargar configuraciones base
require("core.plugins")
require("core.lsp") -- Carga LSP base (sin Python)

-- Configurar Pyright específicamente para este perfil
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({
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
})

-- Configuraciones específicas de Python
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	callback = function()
		-- Configurar indentación para archivos Python
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true

		-- Configurar longitud de línea para Python
		vim.opt_local.textwidth = 88
		vim.opt_local.colorcolumn = "88"
	end,
})

-- Atajos de teclado específicos para Python
vim.api.nvim_set_keymap("n", "<leader>pf", ":Black<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pr", ":!pytest %<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pt", ":!python -m pytest<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>pi", ":!python %<CR>", { noremap = true, silent = true })

-- Formato automático con Black
vim.cmd([[autocmd BufWritePre *.py lua vim.lsp.buf.format()]])

-- Comandos útiles para Python
vim.api.nvim_create_user_command("PythonRepl", function()
	vim.cmd("!python3")
end, {})

vim.api.nvim_create_user_command("PipInstall", function(opts)
	vim.cmd("!pip install " .. opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("PythonVenv", function()
	vim.cmd("!python -m venv venv && source venv/bin/activate")
end, {})

print("✅ Perfil Python cargado correctamente")
