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
      vim.g.db_ui_tmp_query_location = "/tmp/nvim_dbui"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_adapter_mysql_options = '-v'

      vim.g.Db_ui_buffer_name_generator = function(opts)
        local name = opts.label or "query"
        local timestamp = os.date("%Y-%m-%d-%H-%M-%S")

        if opts.table and opts.table ~= "" then
          local table_name = opts.table:gsub("%s+", "-")
          return string.format("%s-%s.sql", table_name, timestamp)
        end

        return string.format("%s-%s.sql", name:gsub("%s+", "-"), timestamp)
      end

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
      vim.g.db_ui_disable_mappings_sql = 1
      vim.g.db_ui_execute_on_save = 0

      local db_completion_enabled = true
      local db_error_shown = false

      vim.api.nvim_create_user_command("DBToggleCompletion", function()
        db_completion_enabled = not db_completion_enabled
        db_error_shown = false
        local status = db_completion_enabled and "enabled" or "disabled"
        vim.notify("DB completion " .. status, vim.log.levels.INFO, { title = "DB" })
      end, { desc = "Toggle DB autocompletion" })

      vim.api.nvim_create_user_command("DBSaveQuerySQL", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local db_key = vim.b[bufnr].dbui_db_key_name

        if not db_key then
          vim.notify("Este comando solo funciona en buffers de queries de DB", vim.log.levels.WARN, { title = "DB" })
          return
        end

        vim.ui.input({ prompt = "Save as: " }, function(filename)
          if not filename or filename == "" then
            return
          end

          if not filename:match("%.sql$") then
            filename = filename .. ".sql"
          end

          local save_path = vim.g.db_ui_save_location
          local full_path = string.format("%s/%s", save_path, filename)

          if vim.fn.filereadable(full_path) == 1 then
            vim.notify("Ese archivo ya existe. Elige otro nombre.", vim.log.levels.ERROR, { title = "DB" })
            return
          end

          vim.cmd("write " .. vim.fn.fnameescape(full_path))
          vim.notify("Query guardado: " .. filename, vim.log.levels.INFO, { title = "DB" })
          vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        end)
      end, { desc = "Save query with .sql extension" })

      vim.api.nvim_create_user_command("DBExportCSV", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        if #lines < 1 then
          vim.notify("No hay datos para exportar", vim.log.levels.WARN, { title = "DB" })
          return
        end

        local csv_lines = {}

        for i, line in ipairs(lines) do
          if line:match("|") and not line:match("^[+%-=┼─┤├┴┬│]") then
            local cells = {}
            local col_start = 1

            while true do
              local pipe_pos = line:find("|", col_start)
              if not pipe_pos then break end

              local next_pipe = line:find("|", pipe_pos + 1)
              if not next_pipe then break end

              local cell = line:sub(pipe_pos + 1, next_pipe - 1)
              cell = cell:match("^%s*(.-)%s*$") or cell
              cell = cell:gsub('"', '""')
              table.insert(cells, '"' .. cell .. '"')

              col_start = next_pipe
            end

            if #cells > 0 then
              table.insert(csv_lines, table.concat(cells, ","))
            end
          end
        end

        if #csv_lines == 0 then
          vim.notify("No se encontraron datos para exportar", vim.log.levels.WARN, { title = "DB" })
          return
        end

        local dumps_path = vim.g.db_ui_save_location .. "/dumps"
        if vim.fn.isdirectory(dumps_path) == 0 then
          vim.fn.mkdir(dumps_path, "p")
        end

        local timestamp = os.date("%Y%m%d_%H%M%S")
        local default_filename = string.format("export_%s.csv", timestamp)

        vim.ui.input({ prompt = "Nombre del archivo CSV: ", default = default_filename }, function(filename)
          if not filename or filename == "" then
            return
          end

          if not filename:match("%.csv$") then
            filename = filename .. ".csv"
          end

          local filepath = string.format("%s/%s", dumps_path, filename)

          if vim.fn.filereadable(filepath) == 1 then
            vim.notify("Ese archivo ya existe. Elige otro nombre.", vim.log.levels.ERROR, { title = "DB" })
            return
          end

          local file = io.open(filepath, "w")
          if not file then
            vim.notify("No se pudo crear el archivo: " .. filepath, vim.log.levels.ERROR, { title = "DB" })
            return
          end

          for _, csv_line in ipairs(csv_lines) do
            file:write(csv_line .. "\n")
          end
          file:close()

          vim.notify(string.format("Exportado a: %s (%d filas)", filename, #csv_lines - 1), vim.log.levels.INFO, { title = "DB" })
        end)
      end, { desc = "Export DB results to CSV" })

      local function generate_alias(table_name)
        local parts = {}
        for part in string.gmatch(table_name, "[^_]+") do
          table.insert(parts, part:sub(1, 1))
        end
        return table.concat(parts, "")
      end

      local function is_table_context(line, col)
        local before_cursor = line:sub(1, col)
        local lower = before_cursor:lower()
        return lower:match("from%s+[%w_]*$")
          or lower:match("join%s+[%w_]*$")
          or lower:match("update%s+[%w_]*$")
      end

      local db_source = require("cmp").register_source("vim-dadbod-completion-safe", {
        complete = function(self, params, callback)
          local success, result = pcall(function()
            local original_source = require("vim_dadbod_completion").nvim_cmp_source
            local items = {}
            original_source:complete(params, function(response)
              items = response.items or {}
            end)
            return items
          end)

          if success then
            db_error_shown = false
            local line = params.context.cursor_line
            local col = params.context.cursor.col

            if is_table_context(line, col) then
              for _, item in ipairs(result or {}) do
                if item.kind == 7 then
                  local table_name = item.label
                  local alias = generate_alias(table_name)
                  item.insertText = string.format("%s as %s", table_name, alias)
                  item.label = string.format("%s as %s", table_name, alias)
                end
              end
            end

            callback({ items = result or {}, isIncomplete = true })
          else
            if not db_error_shown then
              vim.notify("No hay conexion al servidor de BD", vim.log.levels.WARN, { title = "DB" })
              db_error_shown = true
            end
            callback({ items = {}, isIncomplete = false })
          end
        end,

        is_available = function()
          return true
        end,

        get_debug_name = function()
          return "vim-dadbod-completion-safe"
        end,

        get_trigger_characters = function()
          return { '"', "`", "[", "]", "." }
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          db_error_shown = false
          local sources = { { name = "buffer" } }
          if db_completion_enabled then
            table.insert(sources, 1, { name = "vim-dadbod-completion-safe" })
          end

          require("cmp").setup.buffer({ sources = sources })
        end,
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.sql", "*" },
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft ~= "sql" and ft ~= "mysql" and ft ~= "plsql" then
            return
          end

          local filepath = vim.api.nvim_buf_get_name(args.buf)
          if filepath == "" then
            return
          end

          if not filepath:match("%.sql$") then
            local new_filepath = filepath .. ".sql"
            vim.api.nvim_buf_set_name(args.buf, new_filepath)
          end
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
      { "<leader>sw", "<cmd>DBSaveQuerySQL<cr>", desc = "Save Query" },
      { "<leader>sc", "<cmd>DBExportCSV<cr>", desc = "Export to CSV" },
      { "<leader>st", "<cmd>DBToggleCompletion<cr>", desc = "Toggle DB Completion" },
    },
  },
}
