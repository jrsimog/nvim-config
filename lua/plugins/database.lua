-- lua/plugins/database.lua - Database management with vim-dadbod (Multi-environment support)
return {
	-- Main database engine
	{
		"tpope/vim-dadbod",
		lazy = true,
	},

	-- Database UI
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
			-- Database UI settings
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_force_echo_notifications = 1
			vim.g.db_ui_win_position = "left"
			vim.g.db_ui_winwidth = 40

			-- Save queries to Google Drive
			vim.g.db_ui_save_location = vim.fn.expand("~/Google Drive/SQL-Collections")

			-- Use default icons
			vim.g.db_ui_icons = {
				expanded = {
					db = "▾ ",
					buffers = "▾ ",
					saved_queries = "▾ ",
					schemas = "▾ ",
					schema = "▾ 󰙅",
					tables = "▾ 󰓫",
					table = "▾ ",
				},
				collapsed = {
					db = "▸ ",
					buffers = "▸ ",
					saved_queries = "▸ ",
					schemas = "▸ ",
					schema = "▸ 󰙅",
					tables = "▸ 󰓫",
					table = "▸ ",
				},
				saved_query = "",
				new_query = "璘",
				tables = "󰓫",
				buffers = "»",
				add_connection = "",
				connection_ok = "✓",
				connection_error = "✕",
			}

			-- Custom table helpers (optional, to show additional info)
			vim.g.db_ui_table_helpers = {
				mysql = {
					Count = "SELECT COUNT(1) FROM {optional_schema}{table}",
					Explain = "EXPLAIN {last_query}",
				},
				postgresql = {
					Count = "SELECT COUNT(1) FROM {optional_schema}{table}",
					Explain = "EXPLAIN ANALYZE {last_query}",
				},
			}

			-- Execute query settings
			vim.g.db_ui_execute_on_save = 0
			vim.g.db_ui_auto_execute_table_helpers = 0
		end,
		config = function()
			-- Google Drive SQL Collections setup with multi-environment support
			local GDRIVE_SQL_PATH = vim.fn.expand("~/Google Drive/SQL-Collections")
			local CURRENT_SQL_PROJECT = ""
			local CURRENT_ENVIRONMENT = "local" -- Default environment: local, qa, prod

			-- Environment configuration
			local ENVIRONMENTS = { "local", "qa", "prod" }

			-- Ensure directory structure exists
			local function ensure_sql_structure()
				local dirs = {
					GDRIVE_SQL_PATH,
					GDRIVE_SQL_PATH .. "/connections",
					GDRIVE_SQL_PATH .. "/shared-queries",
					GDRIVE_SQL_PATH .. "/templates",
				}

				for _, dir in ipairs(dirs) do
					if vim.fn.isdirectory(dir) == 0 then
						vim.fn.mkdir(dir, "p")
					end
				end

				-- Create environment-specific connection templates
				for _, env in ipairs(ENVIRONMENTS) do
					local template_path = GDRIVE_SQL_PATH .. "/connections/" .. env .. "-connections.json"
					if vim.fn.filereadable(template_path) == 0 then
						local template_content = [[{
  "project_name_]] .. env .. [[": "mysql://user:password@]] .. env .. [[-host:3306/database",
  "another_project_]] .. env .. [[": "postgresql://user:password@]] .. env .. [[-host:5432/database"
}
]]
						local file = io.open(template_path, "w")
						if file then
							file:write(template_content)
							file:close()
						end
					end
				end

				-- Create master connections README
				local readme_path = GDRIVE_SQL_PATH .. "/connections/README.md"
				if vim.fn.filereadable(readme_path) == 0 then
					local readme_content = [[# Database Connections Configuration

## Environments

This directory contains connection configurations for different environments:

- `local-connections.json`: Local development databases
- `qa-connections.json`: QA/Testing environment databases
- `prod-connections.json`: Production databases

## Format

Each file should be a JSON object with connection URLs:

```json
{
  "project_name_env": "protocol://user:password@host:port/database"
}
```

## Supported Protocols

- MySQL: `mysql://user:password@host:port/database`
- PostgreSQL: `postgresql://user:password@host:port/database`
- SQLite: `sqlite:///absolute/path/to/file.db`
- SQL Server: `sqlserver://user:password@host:port/database`

## Security

⚠️ IMPORTANT: Keep these files secure. They contain database credentials.
- Never commit to public repositories
- Use environment variables for sensitive data when possible
- Ensure Google Drive has 2FA enabled

## Environment Variables (Optional)

You can use environment variables in connection strings:
`mysql://$DB_USER:$DB_PASS@host:3306/database`
]]
					local file = io.open(readme_path, "w")
					if file then
						file:write(readme_content)
						file:close()
					end
				end
			end

			-- List SQL projects
			local function list_sql_projects()
				local projects = {}
				local handle = io.popen(
					'find "'
						.. GDRIVE_SQL_PATH
						.. '" -maxdepth 1 -type d -not -path "*/connections" -not -path "*/shared-queries" -not -path "*/templates" -not -path "'
						.. GDRIVE_SQL_PATH
						.. '"'
				)

				if handle then
					for line in handle:lines() do
						local project_name = line:match("([^/]+)$")
						if project_name then
							table.insert(projects, project_name)
						end
					end
					handle:close()
				end

				return projects
			end

			-- Create new SQL project with multi-environment support
			local function create_sql_project()
				vim.ui.input({
					prompt = "Nombre del nuevo proyecto SQL: ",
				}, function(project_name)
					if project_name and project_name ~= "" then
						local project_path = GDRIVE_SQL_PATH .. "/" .. project_name
						vim.fn.mkdir(project_path, "p")

						-- Create environment-specific directories
						for _, env in ipairs(ENVIRONMENTS) do
							vim.fn.mkdir(project_path .. "/" .. env, "p")
							vim.fn.mkdir(project_path .. "/" .. env .. "/queries", "p")
							vim.fn.mkdir(project_path .. "/" .. env .. "/migrations", "p")
						end

						-- Create shared directories
						vim.fn.mkdir(project_path .. "/shared", "p")
						vim.fn.mkdir(project_path .. "/backups", "p")
						vim.fn.mkdir(project_path .. "/docs", "p")

						-- Create README
						local readme_content = [[# SQL Project: ]] .. project_name .. [[

## Estructura del proyecto (Multi-ambiente)

### Ambientes

Este proyecto tiene 3 ambientes separados:

- **`local/`**: Base de datos local de desarrollo
- **`qa/`**: Base de datos de pruebas/QA
- **`prod/`**: Base de datos de producción

Cada ambiente contiene:
- `queries/`: Consultas SQL específicas del ambiente
- `migrations/`: Scripts de migración

### Directorios compartidos

- `shared/`: Consultas SQL que se usan en todos los ambientes
- `backups/`: Respaldos de consultas importantes
- `docs/`: Documentación del proyecto

## Conexiones

Configura tus conexiones para cada ambiente en:

- Local: `~/Google Drive/SQL-Collections/connections/local-connections.json`
- QA: `~/Google Drive/SQL-Collections/connections/qa-connections.json`
- Prod: `~/Google Drive/SQL-Collections/connections/prod-connections.json`

Formato:
```json
{
  "]] .. project_name .. [[_local": "mysql://user:pass@localhost:3306/]] .. project_name .. [[",
  "]] .. project_name .. [[_qa": "mysql://user:pass@qa-host:3306/]] .. project_name .. [[_qa",
  "]] .. project_name .. [[_prod": "mysql://user:pass@prod-host:3306/]] .. project_name .. [["
}
```

## Uso en Neovim

### Cambiar de ambiente
`:SqlSwitchEnv` - Cambia entre local/qa/prod

### Comandos por ambiente
- `:SqlNewFile` - Crea archivo en el ambiente actual
- `:SqlListFiles` - Lista archivos del ambiente actual
- `:SqlInfo` - Muestra ambiente y proyecto actual

## Notas

Agrega aquí notas sobre el proyecto...
]]

						local readme_path = project_path .. "/README.md"
						local file = io.open(readme_path, "w")
						if file then
							file:write(readme_content)
							file:close()
						end

						-- Create example queries for each environment
						for _, env in ipairs(ENVIRONMENTS) do
							local example_query = [[-- Example query for ]] .. project_name .. [[ (]] .. env .. [[ environment)
-- Environment: ]] .. string.upper(env) .. [[


-- SELECT query example
SELECT
    id,
    name,
    email,
    created_at
FROM users
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT 10;

-- Environment-specific note:
]] .. (env == "prod" and "-- ⚠️ PRODUCTION: Be extra careful with DML operations!" or "-- Development environment - safe to test")
								.. [[


-- INSERT example
-- INSERT INTO users (name, email, status)
-- VALUES ('John Doe', 'john@example.com', 'active');

-- UPDATE example
-- UPDATE users
-- SET status = 'inactive'
-- WHERE id = 1;

-- DELETE example (commented for safety)
-- DELETE FROM users WHERE id = 1;
]]

							local query_path = project_path .. "/" .. env .. "/queries/example.sql"
							local query_file = io.open(query_path, "w")
							if query_file then
								query_file:write(example_query)
								query_file:close()
							end
						end

						-- Create shared query example
						local shared_query = [[-- Shared query for ]] .. project_name .. [[

-- This query can be used across all environments (local, qa, prod)
-- Make sure it's environment-agnostic (no hardcoded values)

-- Example: Get table structure
SHOW TABLES;

-- Example: Count records
SELECT
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM users WHERE status = 'active') as active_users;
]]
						local shared_path = project_path .. "/shared/common-queries.sql"
						local shared_file = io.open(shared_path, "w")
						if shared_file then
							shared_file:write(shared_query)
							shared_file:close()
						end

						vim.cmd("edit " .. readme_path)
						print("✅ Proyecto SQL '" .. project_name .. "' creado con 3 ambientes (local, qa, prod)")
					end
				end)
			end

			-- Switch environment
			local function switch_environment()
				vim.ui.select(ENVIRONMENTS, {
					prompt = "Selecciona el ambiente:",
					format_item = function(env)
						local icon = env == CURRENT_ENVIRONMENT and "✓ " or "  "
						local emoji = env == "local" and "💻" or (env == "qa" and "🧪" or "🚀")
						return icon .. emoji .. " " .. string.upper(env)
					end,
				}, function(choice)
					if choice then
						CURRENT_ENVIRONMENT = choice
						local icon = choice == "local" and "💻" or (choice == "qa" and "🧪" or "🚀")
						print(icon .. " Ambiente cambiado a: " .. string.upper(choice))

						-- Update status line or notify
						vim.notify(
							"Ambiente actual: " .. string.upper(choice),
							vim.log.levels.INFO,
							{ title = "SQL Environment" }
						)
					end
				end)
			end

			-- Open SQL project
			local function open_sql_project()
				local projects = list_sql_projects()

				if #projects == 0 then
					print("No hay proyectos SQL disponibles. Crea uno nuevo primero.")
					return
				end

				vim.ui.select(projects, {
					prompt = "Selecciona un proyecto SQL:",
				}, function(choice)
					if choice then
						CURRENT_SQL_PROJECT = choice
						local project_path = GDRIVE_SQL_PATH .. "/" .. choice
						local env_path = project_path .. "/" .. CURRENT_ENVIRONMENT .. "/queries"

						vim.cmd("cd " .. project_path)

						-- Check if environment directory exists
						if vim.fn.isdirectory(env_path) == 1 then
							vim.cmd("Explore " .. env_path)
							print(
								"📂 Proyecto '"
									.. choice
									.. "' abierto ["
									.. string.upper(CURRENT_ENVIRONMENT)
									.. "]"
							)
						else
							vim.cmd("Explore " .. project_path)
							print("⚠️  Proyecto abierto pero ambiente '" .. CURRENT_ENVIRONMENT .. "' no existe")
						end
					end
				end)
			end

			-- Create new SQL file in current project and environment
			local function new_sql_file()
				if CURRENT_SQL_PROJECT == "" then
					print("❌ Primero selecciona un proyecto con :SqlOpenProject")
					return
				end

				vim.ui.input({
					prompt = "Nombre del archivo SQL [" .. string.upper(CURRENT_ENVIRONMENT) .. "]: ",
				}, function(filename)
					if filename and filename ~= "" then
						if not filename:match("%.sql$") then
							filename = filename .. ".sql"
						end

						local file_path = GDRIVE_SQL_PATH
							.. "/"
							.. CURRENT_SQL_PROJECT
							.. "/"
							.. CURRENT_ENVIRONMENT
							.. "/queries/"
							.. filename
						vim.cmd("edit " .. file_path)
						print("📝 Creando: " .. filename .. " [" .. string.upper(CURRENT_ENVIRONMENT) .. "]")
					end
				end)
			end

			-- List SQL files in current project and environment
			local function list_sql_files()
				if CURRENT_SQL_PROJECT == "" then
					print("❌ Primero selecciona un proyecto SQL")
					return
				end

				local project_path = GDRIVE_SQL_PATH
					.. "/"
					.. CURRENT_SQL_PROJECT
					.. "/"
					.. CURRENT_ENVIRONMENT
					.. "/queries"
				local files = {}

				local handle = io.popen('find "' .. project_path .. '" -name "*.sql" -type f 2>/dev/null')
				if handle then
					for line in handle:lines() do
						local filename = line:match("([^/]+)$")
						if filename then
							table.insert(files, {
								name = filename,
								path = line,
							})
						end
					end
					handle:close()
				end

				if #files == 0 then
					print("📂 No hay archivos SQL en " .. string.upper(CURRENT_ENVIRONMENT))
					return
				end

				local file_names = {}
				for _, file in ipairs(files) do
					table.insert(file_names, file.name)
				end

				vim.ui.select(file_names, {
					prompt = "Archivos SQL [" .. string.upper(CURRENT_ENVIRONMENT) .. "]:",
				}, function(choice)
					if choice then
						for _, file in ipairs(files) do
							if file.name == choice then
								vim.cmd("edit " .. file.path)
								break
							end
						end
					end
				end)
			end

			-- Open connections for current environment
			local function open_env_connections()
				local conn_path = GDRIVE_SQL_PATH .. "/connections/" .. CURRENT_ENVIRONMENT .. "-connections.json"
				vim.cmd("edit " .. conn_path)
				print("⚙️  Editando conexiones de " .. string.upper(CURRENT_ENVIRONMENT))
			end

			-- Global functions for keymaps
			_G.sql_gdrive = {
				open_project = open_sql_project,
				create_project = create_sql_project,
				new_sql_file = new_sql_file,
				list_sql_files = list_sql_files,
				switch_environment = switch_environment,
				sql_home = function()
					vim.cmd("cd " .. GDRIVE_SQL_PATH)
					vim.cmd("Explore " .. GDRIVE_SQL_PATH)
				end,
				sql_info = function()
					local env_icon = CURRENT_ENVIRONMENT == "local" and "💻"
						or (CURRENT_ENVIRONMENT == "qa" and "🧪" or "🚀")
					print("📊 Información SQL:")
					print("  Directorio: " .. GDRIVE_SQL_PATH)
					print("  Proyecto actual: " .. (CURRENT_SQL_PROJECT ~= "" and CURRENT_SQL_PROJECT or "❌ Ninguno"))
					print("  " .. env_icon .. " Ambiente: " .. string.upper(CURRENT_ENVIRONMENT))
					print("  Proyectos disponibles: " .. #list_sql_projects())
				end,
				open_connections = open_env_connections,
			}

			-- Initialize structure
			ensure_sql_structure()

			-- User commands
			vim.api.nvim_create_user_command(
				"SqlHome",
				_G.sql_gdrive.sql_home,
				{ desc = "Database: Open SQL collections directory" }
			)
			vim.api.nvim_create_user_command(
				"SqlInfo",
				_G.sql_gdrive.sql_info,
				{ desc = "Database: Show current project and environment info" }
			)
			vim.api.nvim_create_user_command(
				"SqlNewProject",
				_G.sql_gdrive.create_project,
				{ desc = "Database: Create new multi-environment SQL project" }
			)
			vim.api.nvim_create_user_command(
				"SqlOpenProject",
				_G.sql_gdrive.open_project,
				{ desc = "Database: Open existing SQL project" }
			)
			vim.api.nvim_create_user_command(
				"SqlNewFile",
				_G.sql_gdrive.new_sql_file,
				{ desc = "Database: Create new SQL file in current environment" }
			)
			vim.api.nvim_create_user_command(
				"SqlListFiles",
				_G.sql_gdrive.list_sql_files,
				{ desc = "Database: List SQL files in current environment" }
			)
			vim.api.nvim_create_user_command(
				"SqlConnections",
				_G.sql_gdrive.open_connections,
				{ desc = "Database: Edit connections for current environment" }
			)
			vim.api.nvim_create_user_command(
				"SqlSwitchEnv",
				_G.sql_gdrive.switch_environment,
				{ desc = "Database: Switch between local/qa/prod environments" }
			)

			-- Show current environment on startup (if project is set)
			vim.defer_fn(function()
				if CURRENT_SQL_PROJECT ~= "" then
					local env_icon = CURRENT_ENVIRONMENT == "local" and "💻"
						or (CURRENT_ENVIRONMENT == "qa" and "🧪" or "🚀")
					print(env_icon .. " SQL Environment: " .. string.upper(CURRENT_ENVIRONMENT))
				end
			end, 100)
		end,
	},

	-- SQL completion for nvim-cmp
	{
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		lazy = true,
		config = function()
			-- This is handled in the cmp configuration
			-- Just make sure it's available for SQL filetypes
		end,
	},
}
