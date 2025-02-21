local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup {
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  git = {
    enable = true,
    ignore = false,
  },
  view = {
    width = 30,
    side = 'left',
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      }
    }
  },
}
