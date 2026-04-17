local log_dir = vim.fn.expand("~/GDRIVE_NVIM_RESOURCES/logs")

vim.env.NVIM_LOG_FILE = log_dir .. "/nvim.log"
vim.lsp.log.set_level("warn")
vim.lsp.log._set_filename(log_dir .. "/lsp.log")
