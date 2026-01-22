return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local theme = require("lualine.themes.auto")
    theme.normal.a.bg = "#808080"
    theme.normal.a.fg = "#FFFFFF"
    theme.insert.a.bg = "#33A333"
    theme.insert.a.fg = "#FFFFFF"
    theme.visual.a.bg = "#FFFF00"
    theme.visual.a.fg = "#000000"
    theme.command.a.bg = "#87CEEB"
    theme.command.a.fg = "#000000"

    local function get_project_path()
      return vim.fn.getcwd()
    end

    local function get_relative_filepath()
      local filepath = vim.fn.expand("%:p")
      local cwd = vim.fn.getcwd()
      if filepath == "" then
        return "[No Name]"
      end
      if filepath:sub(1, #cwd) == cwd then
        return filepath:sub(#cwd + 2)
      end
      return filepath
    end

    require("lualine").setup({
      options = {
        theme = theme,
        icons_enabled = true,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        always_divide_middle = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = { get_project_path, "branch", get_relative_filepath },
        lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
    })
  end,
}
