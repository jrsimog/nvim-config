return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (workspace)" },
    { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
    { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols outline" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
  },
  config = function()
    require("trouble").setup({
      modes = {
        diagnostics = {
          auto_close = false,
          auto_preview = true,
        },
      },
    })
  end,
}
