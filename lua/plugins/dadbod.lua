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
      vim.g.db_adapter_mysql_options = '-v'

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
      vim.g.db_ui_disable_mappings = 0
      vim.g.db_ui_execute_on_save = 0

      local db_completion_enabled = true

      vim.api.nvim_create_user_command("DBToggleCompletion", function()
        db_completion_enabled = not db_completion_enabled
        local status = db_completion_enabled and "enabled" or "disabled"
        vim.notify("DB completion " .. status, vim.log.levels.INFO, { title = "DB" })
      end, { desc = "Toggle DB autocompletion" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          local sources = { { name = "buffer" } }
          if db_completion_enabled then
            local has_db_connection = vim.g.db or (vim.b.db and vim.b.db ~= "")
            if has_db_connection then
              table.insert(sources, 1, { name = "vim-dadbod-completion" })
            else
              vim.notify("No hay conexion al servidor de BD", vim.log.levels.WARN, { title = "DB" })
            end
          end

          require("cmp").setup.buffer({ sources = sources })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "DBQueryExecuted",
        callback = function()
          local info = vim.g.db_last_query_info
          if info and info.query and info.rows then
            local query_lower = string.lower(info.query)
            if string.find(query_lower, "^%s*insert") or string.find(query_lower, "^%s*update") then
              local action_text = ""
              if string.find(query_lower, "^%s*insert") then
                action_text = "Insert"
              elseif string.find(query_lower, "^%s*update") then
                action_text = "Update"
              end

              local row_plural = "rows"
              if info.rows == 1 then
                row_plural = "row"
              end
              vim.notify(action_text .. " " .. info.rows .. " " .. row_plural, vim.log.levels.INFO, { title = "DB" })
            end
          end
        end,
      })
    end,
    keys = {
      { "<leader>sq", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
      { "<leader>sa", "<cmd>DBUIAddConnection<cr>", desc = "Add DB Connection" },
      { "<leader>sf", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
      { "<leader>se", "<Plug>(DBUI_ExecuteQuery)", mode = { "n", "v" }, desc = "Execute Query" },
      { "<leader>st", "<cmd>DBToggleCompletion<cr>", desc = "Toggle DB Completion" },
    },
  },
}
