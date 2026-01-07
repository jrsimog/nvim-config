return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
  keys = {
    { "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Open git diff (local changes)" },
    {
      "<leader>db",
      function()
        vim.ui.input({ prompt = "Compare with branch: ", default = "main" }, function(branch)
          if branch and branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch)
          end
        end)
      end,
      desc = "Diff with branch"
    },
    { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close git diff" },
    { "<leader>dq", "<cmd>DiffviewClose<cr>", desc = "Quit git diff" },
    { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      use_icons = true,
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      commit_log_panel = {
        win_config = {},
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {},
      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" } },
          { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle file panel" } },
          { "n", "[c", "<cmd>lua require('diffview.actions').prev_conflict()<cr>", { desc = "Previous conflict" } },
          { "n", "]c", "<cmd>lua require('diffview.actions').next_conflict()<cr>", { desc = "Next conflict" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file_edit()<cr>", { desc = "Go to file" } },
          { "n", "do", "<cmd>diffget<cr>", { desc = "Get changes from master" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open diff" } },
          { "n", "s", "<cmd>lua require('diffview.actions').toggle_stage_entry()<cr>", { desc = "Stage/unstage" } },
          { "n", "r", "<cmd>lua require('diffview.actions').restore_entry()<cr>", { desc = "Restore file from other branch" } },
          { "n", "R", "<cmd>lua require('diffview.actions').refresh_files()<cr>", { desc = "Refresh files" } },
          { "n", "gf", "<cmd>lua require('diffview.actions').goto_file_edit()<cr>", { desc = "Go to file" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diff view" } },
          { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open diff" } },
          { "n", "r", "<cmd>lua require('diffview.actions').restore_entry()<cr>", { desc = "Restore file from commit" } },
        },
      },
    })
  end,
}
