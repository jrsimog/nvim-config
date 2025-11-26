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

      if string.match(file_path_absolute, "%.http$") then
        return vim.fn.fnamemodify(path, ":t")
      end

      local home = vim.fn.expand("~")
      if string.find(file_path_absolute, home, 1, true) == 1 then
        local path_from_home = "~" .. string.sub(file_path_absolute, #home + 1)
        local parts = {}
        for part in string.gmatch(path_from_home, "[^/]+") do
          table.insert(parts, part)
        end
        if #parts > 3 then
          return ".../" .. parts[#parts - 1] .. "/" .. parts[#parts]
        end
        return path_from_home
      end

      return vim.fn.fnamemodify(path, ":~:.")
    end

    telescope.setup({
      defaults = {
        path_display = project_path_display,
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
      pickers = {
        find_files = {
          case_mode = "ignore_case",
        },
        live_grep = {
          case_mode = "ignore_case",
        },
        grep_string = {
          case_mode = "ignore_case",
        },
        buffers = {
          case_mode = "ignore_case",
        },
        current_buffer_fuzzy_find = {
          case_mode = "ignore_case",
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

    local function search_current_buffer()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local previewers = require("telescope.previewers")

      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      local entries = {}
      for lnum, line in ipairs(lines) do
        table.insert(entries, {
          lnum = lnum,
          text = line,
          display = string.format("%4d: %s", lnum, line),
        })
      end

      pickers.new({}, {
        prompt_title = "Search Current Buffer",
        finder = finders.new_table({
          results = entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.text,
              lnum = entry.lnum,
              filename = filepath,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
          define_preview = function(self, entry)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.api.nvim_buf_call(self.state.bufnr, function()
              vim.fn.cursor(entry.lnum, 1)
            end)
          end,
        }),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
          end)
          return true
        end,
      }):find()
    end

    keymap.set("n", "<leader>fl", search_current_buffer, { desc = "Search in current buffer" })
    keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
    keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find symbols in document" })
    keymap.set("n", "<leader>fw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Find symbols in workspace" })
    keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
  end,
}
