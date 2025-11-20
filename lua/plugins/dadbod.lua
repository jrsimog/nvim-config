return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      local db_path = "/home/jose/GoogleDrive/GDRIVE_NVIM_RESOURCES/DB"

      vim.g.db_ui_save_location = db_path
      vim.g.db_ui_tmp_query_location = db_path .. "/tmp"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1

      vim.g.db_ui_table_helpers = {
        postgresql = {
          Count = "SELECT COUNT(*) FROM {table}",
          Columns = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '{table}'",
        },
        mysql = {
          Count = "SELECT COUNT(*) FROM {table}",
          Columns = "DESCRIBE {table}",
        },
      }
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })
    end,
    keys = {
      { "<leader>sq", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
      { "<leader>sa", "<cmd>DBUIAddConnection<cr>", desc = "Add DB Connection" },
      { "<leader>sf", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
    },
  },
}
