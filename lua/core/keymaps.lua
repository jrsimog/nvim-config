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
keymap.set("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git pull" })
keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })

keymap.set("n", "<leader>gc", function()
  if vim.fn.isdirectory(".git") == 1 then
    vim.ui.input({ prompt = "Commit message: " }, function(message)
      if message and message ~= "" then
        local result = vim.fn.system("git commit -m " .. vim.fn.shellescape(message))

        if vim.v.shell_error == 0 then
          vim.notify("Commit created successfully", vim.log.levels.INFO)
        else
          vim.notify("Commit failed: " .. result, vim.log.levels.ERROR)
        end
      else
        vim.notify("Commit cancelled: empty message", vim.log.levels.WARN)
      end
    end)
  else
    vim.notify("Not a git repository", vim.log.levels.WARN)
  end
end, { desc = "Git commit" })

keymap.set("n", "<leader>gu", function()
  if vim.fn.isdirectory(".git") == 1 then
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local unpushed_commits = vim.fn.systemlist("git log @{u}.. --oneline 2>/dev/null")
    local has_upstream = vim.v.shell_error == 0

    if (has_upstream and #unpushed_commits > 0) or not has_upstream then
      local commits = has_upstream and unpushed_commits or vim.fn.systemlist("git log --oneline -n 10")

      pickers.new({}, {
        prompt_title = has_upstream and "Unpushed Commits (Select to Undo)" or "Recent Commits (No upstream - Select to Undo)",
        finder = finders.new_table({
          results = commits,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_termopen_previewer({
          get_command = function(entry)
            local hash = entry.value:match("^(%w+)")
            return { "git", "show", "--stat", "--pretty=format:%H%n%an <%ae>%n%ad%n%n%s%n%n%b", hash }
          end,
        }),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            local hash = selection.value:match("^(%w+)")

            vim.ui.input({ prompt = "Undo this commit? (y/N): " }, function(input)
              if input and input:lower() == "y" then
                local current_hash = vim.fn.system("git rev-parse HEAD"):gsub("\n", "")
                if hash == current_hash:sub(1, #hash) then
                  vim.fn.system("git reset --soft HEAD~1")
                  if vim.v.shell_error == 0 then
                    vim.notify("Commit undone, changes kept in staging", vim.log.levels.INFO)
                  else
                    vim.notify("Failed to undo commit", vim.log.levels.ERROR)
                  end
                else
                  vim.notify("Can only undo the most recent commit (HEAD)", vim.log.levels.WARN)
                end
              else
                vim.notify("Undo cancelled", vim.log.levels.WARN)
              end
            end)
          end)
          return true
        end,
      }):find()
    else
      vim.notify("No unpushed commits to undo", vim.log.levels.WARN)
    end
  else
    vim.notify("Not a git repository", vim.log.levels.WARN)
  end
end, { desc = "Undo last commit (if not pushed)" })

keymap.set("n", "<leader>gs", function()
  if vim.fn.isdirectory(".git") == 1 then
    vim.cmd("Telescope git_status")
  else
    vim.notify("Not a git repository", vim.log.levels.WARN)
  end
end, { desc = "Git status (Telescope)" })

keymap.set("n", "<leader>gg", function()
  if vim.fn.isdirectory(".git") == 1 then
    vim.cmd("Telescope git_commits")
  else
    vim.notify("Not a git repository", vim.log.levels.WARN)
  end
end, { desc = "Git commits (Telescope)" })

vim.api.nvim_create_user_command("Bda", function()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end, { desc = "Delete all buffers except current" })
