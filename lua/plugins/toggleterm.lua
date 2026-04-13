return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-\\>", desc = "Toggle terminal" },
  },
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = {
        border = "rounded",
      },
      -- Mantener navegación entre ventanas dentro del terminal
      on_open = function()
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { buffer = true })
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { buffer = true })
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { buffer = true })
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { buffer = true })
      end,
    })
  end,
}
