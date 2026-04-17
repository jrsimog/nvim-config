local log_dir = vim.fn.expand("~/GDRIVE_NVIM_RESOURCES/logs")

vim.env.NVIM_LOG_FILE = log_dir .. "/nvim.log"
vim.lsp.set_log_level("warn")
vim.lsp.log.set_logfile(log_dir .. "/lsp.log")
