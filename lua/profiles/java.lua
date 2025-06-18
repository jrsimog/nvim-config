-- lua/profiles/java.lua
-- Perfil para Java
print("☕ Cargando perfil Java")

vim.g.mapleader = " "

-- Cargar configuraciones base
require("core.plugins")
require("core.lsp") -- Carga LSP base (sin Java)

-- Configurar jdtls específicamente para este perfil
local lspconfig = require("lspconfig")
lspconfig.jdtls.setup({
	cmd = { "jdtls" },
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
})

-- Configuraciones específicas de Java
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "java" },
	callback = function()
		-- Configurar indentación para archivos Java
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = true

		-- Configurar longitud de línea para Java
		vim.opt_local.textwidth = 120
		vim.opt_local.colorcolumn = "120"
	end,
})

-- Atajos de teclado específicos para Java
vim.api.nvim_set_keymap("n", "<leader>jc", ":JdtCompile<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>jr", ":JdtUpdateConfig<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ji", ":JdtOrganizeImports<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>jt", ":JdtTestClass<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>jm", ":!mvn compile<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>jr", ":!mvn test<CR>", { noremap = true, silent = true })

-- Formato automático con Google Java Format
vim.cmd([[autocmd BufWritePre *.java lua vim.lsp.buf.format()]])

-- Comandos útiles para Java
vim.api.nvim_create_user_command("JavaCompile", function()
	local file = vim.fn.expand("%:t:r")
	vim.cmd("!javac " .. vim.fn.expand("%") .. " && java " .. file)
end, {})

vim.api.nvim_create_user_command("MavenClean", function()
	vim.cmd("!mvn clean")
end, {})

vim.api.nvim_create_user_command("MavenPackage", function()
	vim.cmd("!mvn package")
end, {})

print("✅ Perfil Java cargado correctamente")
