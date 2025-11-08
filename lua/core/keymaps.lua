local keymap = vim.keymap

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete to void register" })

keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
