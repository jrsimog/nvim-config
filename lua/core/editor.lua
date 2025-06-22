-- lua/core/editor.lua
vim.cmd([[
  autocmd FileType diff setlocal foldmethod=manual foldlevel=999
  autocmd BufWinEnter,WinEnter * if &diff | set foldlevel=999 | endif
]])

vim.opt.diffopt:append("vertical")

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.filereadable(".git/MERGE_HEAD") == 1 then
			print("🌪️  Resolviendo un merge… usa <leader>do y <leader>dt para elegir lados.")
		end
	end,
})
