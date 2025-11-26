return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    local function project_path_display(_, path)
      local cwd = vim.fn.getcwd()
      local file_path_absolute = vim.fn.fnamemodify(path, ":p")

      if string.find(file_path_absolute, cwd, 1, true) == 1 then
        local file_path_relative = string.sub(file_path_absolute, #cwd + 2)
        return file_path_relative
      end

      return path
    end

    telescope.setup({
      defaults = {
        path_display = project_path_display,
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = vim.keymap

    keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files in cwd" })
    local function oldfiles_and_cd()
      require("telescope.builtin").oldfiles({
        attach_mappings = function(prompt_bufnr, map)
          local function open_file_and_cd()
            local action_state = require("telescope.actions.state")
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd("edit " .. selection.path)
              vim.cmd("cd " .. vim.fn.fnamemodify(selection.path, ":h"))
            end
          end

          map("i", "<cr>", open_file_and_cd)
          map("n", "<cr>", open_file_and_cd)

          return true
        end,
      })
    end

    keymap.set("n", "<leader>fr", oldfiles_and_cd, { desc = "Find recent files (and cd to dir)" })
    keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep text in project" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find case_mode=ignore_case<cr>", { desc = "Fuzzy find in current buffer" })
    keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
    keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find symbols in document" })
    keymap.set("n", "<leader>fw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Find symbols in workspace" })
    keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
  end,
}
