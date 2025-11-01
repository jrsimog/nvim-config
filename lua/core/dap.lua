-- dap.lua - Configuración de Debug Adapter Protocol (DAP) para Neovim

local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
	return
end

-- Configuración para Node.js

dap.adapters.node2 = {
	type = "executable",
	command = "node",
	args = { os.getenv("HOME") .. "/.config/nvim/debuggers/vscode-node-debug2/out/src/nodeDebug.js" },
}

dap.configurations.javascript = {
	{
		type = "node2",
		request = "launch",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
}

dap.adapters.python = {
	type = "executable",
	command = "python3",
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		program = "${file}",
		pythonPath = function()
			return "/usr/bin/python3"
		end,
	},
}

dap.adapters.mix_task = {
	type = "executable",
	command = "elixir",
	args = { "--sname", "debugger", "-S", "mix", "debugger" },
}

dap.configurations.elixir = {
	{
		type = "mix_task",
		request = "launch",
		task = "phx.server",
		projectDir = vim.fn.getcwd(),
	},
}

dap.adapters.php = {
	type = "executable",
	command = "node",
	args = { os.getenv("HOME") .. "/.config/nvim/debuggers/vscode-php-debug/out/phpDebug.js" },
}

dap.configurations.php = {
	{
		type = "php",
		request = "launch",
		name = "Listen for Xdebug",
		port = 9003,
		pathMappings = {
			["/var/www/html"] = vim.fn.getcwd(),
		},
	},
}

vim.api.nvim_set_keymap("n", "<leader>dc", ':lua require"dap".continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>db",
	':lua require"dap".toggle_breakpoint()<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>do", ':lua require"dap".step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>di", ':lua require"dap".step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>du", ':lua require"dap".step_out()<CR>', { noremap = true, silent = true })
