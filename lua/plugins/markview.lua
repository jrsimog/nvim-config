return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("markview").setup({
      preview = {
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
      },
    })

    vim.keymap.set("n", "<leader>mv", "<cmd>Markview Toggle<cr>", { desc = "Toggle markdown render" })
  end,
}
