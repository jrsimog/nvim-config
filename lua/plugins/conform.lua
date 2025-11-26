return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  config = function()
    local conform = require("conform")

    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      conform.format({ async = true, lsp_fallback = true, range = range })
    end, { range = true, desc = "Format buffer or range" })

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        elixir = { "mix" },
        sql = { "sql_formatter" },
        mysql = { "sql_formatter" },
        plsql = { "sql_formatter" },
      },
      formatters = {
        mix = {
          command = "mix",
          args = { "format", "-" },
          stdin = true,
        },
        sql_formatter = {
          command = "sql-formatter",
          args = { "--config", "/home/jose/.config/nvim/.sql-formatter.json" },
          stdin = true,
        },

      },
      format_on_save = function(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("%.http$") then
          return nil
        end
        return {
          timeout_ms = 2000,
          lsp_fallback = true,
        }
      end,
    })
  end,
}
