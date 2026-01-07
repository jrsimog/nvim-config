local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local general = augroup("General", { clear = true })

autocmd("TextYankPost", {
  group = general,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.foldenable = false
    vim.cmd("normal zR")
  end,
  desc = "Restore cursor position and disable folding",
})

autocmd("FileType", {
  group = general,
  pattern = { "help", "man", "qf" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, desc = "Close with q" })
  end,
  desc = "Close certain filetypes with q",
})

autocmd("BufWinEnter", {
  group = general,
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" then
      vim.wo.number = true
      vim.wo.relativenumber = true
    end
  end,
  desc = "Ensure line numbers in normal buffers",
})

autocmd({ "BufEnter", "BufWinEnter" }, {
  group = general,
  pattern = "*",
  callback = function()
    local bufpath = vim.api.nvim_buf_get_name(0)
    if bufpath == "" or vim.bo.buftype ~= "" then
      return
    end

    local filetype = vim.bo.filetype
    local excluded_filetypes = {
      "DiffviewFiles",
      "DiffviewFileHistory",
      "git",
      "gitcommit",
      "fugitive",
      "NvimTree",
      "neo-tree",
      "toggleterm",
    }

    for _, ft in ipairs(excluded_filetypes) do
      if filetype == ft then
        return
      end
    end

    if not vim.fn.isdirectory(vim.fn.fnamemodify(bufpath, ":p:h")) == 1 then
      return
    end

    local root_patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", "mix.exs" }
    local current_dir = vim.fn.fnamemodify(bufpath, ":p:h")

    local function find_root(path)
      for _, pattern in ipairs(root_patterns) do
        local found = vim.fn.finddir(pattern, path .. ";")
        if found ~= "" then
          return vim.fn.fnamemodify(found, ":p:h:h")
        end
        found = vim.fn.findfile(pattern, path .. ";")
        if found ~= "" then
          return vim.fn.fnamemodify(found, ":p:h")
        end
      end
      return nil
    end

    local root = find_root(current_dir)
    if root and root ~= vim.fn.getcwd() and vim.fn.isdirectory(root) == 1 then
      pcall(vim.cmd, "lcd " .. vim.fn.fnameescape(root))
    end
  end,
  desc = "Auto change to project root",
})
