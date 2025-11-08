return {
  "coffebar/neovim-project",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "Shatur/neovim-session-manager" },
  },
  lazy = false,
  priority = 100,
  config = function()
    require("neovim-project").setup({
      projects = {
        "/var/www/html/*",
      },
      picker = {
        type = "telescope",
      },
      last_session_on_startup = false,
      datapath = vim.fn.stdpath("data"),
    })

    vim.keymap.set("n", "<leader>p", "<cmd>NeovimProjectDiscover<cr>", { desc = "Discover and open projects" })
    vim.keymap.set("n", "<leader>ph", "<cmd>NeovimProjectHistory<cr>", { desc = "Project history" })
  end,
}
