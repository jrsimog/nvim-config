-- lua/plugins/telescope.lua

local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-n>"] = require('telescope.actions').move_selection_next,
        ["<C-p>"] = require('telescope.actions').move_selection_previous,
      },
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

require('telescope').load_extension('fzf')
if not status_ok then
  return
end

telescope.setup {
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = "➜ ",
    path_display = { "truncate" },
    file_ignore_patterns = {
      "node_modules",
      ".git",
      "dist",
      "build"
    },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
    },
  },
}
