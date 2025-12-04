vim.api.nvim_create_user_command("MeetNew", function()
  local url = "https://meet.google.com/new"
  vim.fn.system("xdg-open '" .. url .. "'")
  vim.notify("Opening new Google Meet...", vim.log.levels.INFO)
end, {
  desc = "Open new Google Meet",
})

vim.keymap.set("n", "<leader>mn", "<cmd>MeetNew<cr>", { desc = "New Google Meet" })

return {}
