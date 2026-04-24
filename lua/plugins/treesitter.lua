return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local parsers_to_install = {
      "elixir", "heex", "eex",
      "lua",
      "javascript", "typescript", "tsx",
      "php",
      "java",
      "python",
      "html", "css",
      "json",
      "markdown", "markdown_inline",
      "http",
      "sql",
      "bash",
      "vim", "vimdoc",
    }

    local installed = require("nvim-treesitter.config").get_installed()
    local to_install = vim.tbl_filter(function(lang)
      return not vim.list_contains(installed, lang)
    end, parsers_to_install)

    if #to_install > 0 then
      require("nvim-treesitter.install").install(to_install)
    end

    -- Enable treesitter highlighting for every filetype that has a parser
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

  end,
}
