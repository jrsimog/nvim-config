local M = {}

-- Try to load plenary.path, but handle gracefully if not available
local plenary_path_ok, plenary_path = pcall(require, 'plenary.path')
if not plenary_path_ok then
  -- If plenary is not available, provide fallback functionality
  plenary_path = nil
end

-- Project type definitions
local project_markers = {
  elixir = { 'mix.exs' },
  php = { 'composer.json', 'composer.lock' },
  python = { 'requirements.txt', 'pyproject.toml', 'setup.py', 'Pipfile' },
  java = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'gradlew' },
  javascript = { 'package.json' },
  typescript = { 'tsconfig.json' },
  rust = { 'Cargo.toml' },
  go = { 'go.mod' },
  c = { 'Makefile', 'CMakeLists.txt' },
  cpp = { 'Makefile', 'CMakeLists.txt', 'meson.build' },
  sh = { '.zshrc', '.bashrc', '.bash_profile', '.zprofile', '.bash_aliases' },
}

-- Filetype to profile mapping (for single files without project markers)
local filetype_to_profile = {
  sh = 'sh',
  bash = 'sh',
  zsh = 'sh',
  python = 'python',
  php = 'php',
  elixir = 'elixir',
  java = 'java',
  javascript = 'javascript',
  typescript = 'typescript',
  rust = 'rust',
  go = 'go',
  c = 'c',
  cpp = 'cpp',
}

-- Cache for project types to avoid repeated file system checks
local project_cache = {}
local last_loaded_profile = nil
local lsp_setup_in_progress = false
local last_notification_time = 0

-- Function to detect project type based on markers
function M.detect_project_type(path)
  if not path then
    path = vim.fn.getcwd()
  end

  -- PRIORITY 1: Check current buffer's filetype first for specific file types
  -- This ensures that opening .zshrc or .bashrc loads the shell profile,
  -- even if we're in a PHP/Python/etc project directory
  local current_buffer = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buffer)
  local filename = vim.fn.fnamemodify(current_file, ':t')

  -- Check if it's a shell config file by name
  local shell_config_files = { '.zshrc', '.bashrc', '.bash_profile', '.zprofile', '.bash_aliases', '.zshenv' }
  for _, shell_file in ipairs(shell_config_files) do
    if filename == shell_file or current_file:match(shell_file .. '$') then
      return 'sh'
    end
  end

  -- Check by file extension
  if filename:match('%.sh$') or filename:match('%.bash$') or filename:match('%.zsh$') then
    return 'sh'
  end

  -- Check cache
  if project_cache[path] then
    return project_cache[path]
  end

  -- If plenary is not available, use fallback method
  if not plenary_path then
    -- Simple fallback: just check current directory
    local current_dir = path
    for project_type, markers in pairs(project_markers) do
      for _, marker in ipairs(markers) do
        local marker_path = current_dir .. '/' .. marker
        if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
          project_cache[path] = project_type
          return project_type
        end
      end
    end

    -- No project type detected with fallback, try filetype-based detection
    local filetype = vim.bo.filetype
    if filetype and filetype_to_profile[filetype] then
      project_cache[path] = filetype_to_profile[filetype]
      return filetype_to_profile[filetype]
    end

    -- Still no match, use default
    project_cache[path] = 'default'
    return 'default'
  end

  local project_path = plenary_path:new(path)

  -- Walk up the directory tree looking for project markers
  local current_path = project_path
  while current_path do
    for project_type, markers in pairs(project_markers) do
      for _, marker in ipairs(markers) do
        local marker_path = current_path / marker
        if marker_path:exists() then
          project_cache[path] = project_type
          return project_type
        end
      end
    end

    -- Move up one directory
    local parent = current_path:parent()
    if parent == current_path then
      break -- We've reached the root
    end
    current_path = parent
  end

  -- No project type detected, try filetype-based detection
  local filetype = vim.bo.filetype
  if filetype and filetype_to_profile[filetype] then
    project_cache[path] = filetype_to_profile[filetype]
    return filetype_to_profile[filetype]
  end

  -- Still no match, use default
  project_cache[path] = 'default'
  return 'default'
end

-- Function to check if a profile exists
local function profile_exists(profile_name)
  local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile_name .. ".lua"
  return vim.fn.filereadable(profile_path) == 1
end

-- Function to change profile using the existing system
local function change_profile_internal(profile)
  if not profile_exists(profile) then
    vim.notify('Profile "' .. profile .. '" not found, using default', vim.log.levels.WARN)
    profile = 'default'
    if not profile_exists(profile) then
      vim.notify('Default profile not found either', vim.log.levels.ERROR)
      return false
    end
  end

  -- Clear the loaded module to force reload
  package.loaded["profiles." .. profile] = nil

  local success, result = pcall(require, "profiles." .. profile)

  if success then
    -- If the profile has a setup function, call it
    if type(result) == 'table' and type(result.setup) == 'function' then
      local setup_success, setup_error = pcall(result.setup)
      if not setup_success then
        vim.notify('Error calling setup function for profile "' .. profile .. '": ' .. tostring(setup_error), vim.log.levels.ERROR)
      end
    end
    
    vim.env.NVIM_PROFILE = profile
    last_loaded_profile = profile
    
    -- Only show notification if enough time has passed since last one
    local current_time = vim.loop.hrtime()
    if current_time - last_notification_time > 2000000000 then -- 2 seconds in nanoseconds
      vim.notify('🔄 Auto-switched to ' .. profile .. ' profile', vim.log.levels.INFO)
      last_notification_time = current_time
    end
    
    return true
  else
    vim.notify('Error loading profile "' .. profile .. '": ' .. tostring(result), vim.log.levels.ERROR)
    
    -- Try with dofile as fallback
    local profile_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. profile .. ".lua"
    local dofile_success, dofile_error = pcall(dofile, profile_path)
    
    if dofile_success then
      vim.env.NVIM_PROFILE = profile
      last_loaded_profile = profile
      
      -- Only show notification if enough time has passed since last one
      local current_time = vim.loop.hrtime()
      if current_time - last_notification_time > 2000000000 then -- 2 seconds in nanoseconds
        vim.notify('🔄 Auto-switched to ' .. profile .. ' profile (via dofile)', vim.log.levels.INFO)
        last_notification_time = current_time
      end
      
      return true
    else
      vim.notify('Failed to load with dofile too: ' .. tostring(dofile_error), vim.log.levels.ERROR)
      return false
    end
  end
end

-- Function to load project-specific configuration
function M.load_project_config(project_type)
  if not project_type then
    project_type = M.detect_project_type()
  end

  -- Only change profile if it's different from the current one
  local current_profile = vim.env.NVIM_PROFILE or last_loaded_profile
  if current_profile ~= project_type then
    -- print("🔄 Profile change needed: " .. (current_profile or "none") .. " -> " .. project_type)
    change_profile_internal(project_type)
  else
    -- print("✅ Profile already loaded: " .. project_type)
    -- Verificar si el LSP está realmente activo
    local clients = vim.lsp.get_clients()
    if #clients == 0 and not lsp_setup_in_progress then
      -- print("⚠️  But no LSP clients active - forcing reload")
      lsp_setup_in_progress = true
      change_profile_internal(project_type)
      -- Reset flag after a delay
      vim.defer_fn(function() 
        lsp_setup_in_progress = false 
      end, 2000)
    elseif lsp_setup_in_progress then
      -- print("🔄 LSP setup already in progress, skipping...")
    end
  end
end

-- Function to clear project cache (useful for testing or manual refresh)
function M.clear_cache()
  project_cache = {}
end

-- Function to get current project type without loading config
function M.get_current_project_type()
  return M.detect_project_type()
end

-- Function to force reload current project
function M.reload_current_project()
  M.clear_cache()
  local project_type = M.detect_project_type()
  last_loaded_profile = nil -- Force reload
  M.load_project_config(project_type)
end

-- Debug function to show current status
function M.debug_status()
  local current_dir = vim.fn.getcwd()
  local detected_type = M.detect_project_type()
  local current_profile = vim.env.NVIM_PROFILE or last_loaded_profile or "none"
  
  print("🔍 Project Detection Debug:")
  print("  Current directory: " .. current_dir)
  print("  Detected project type: " .. detected_type)
  print("  Current profile: " .. current_profile)
  print("  Last loaded profile: " .. (last_loaded_profile or "none"))
  
  -- Check for markers in current directory
  local found_markers = {}
  for project_type, markers in pairs(project_markers) do
    for _, marker in ipairs(markers) do
      local marker_path = current_dir .. "/" .. marker
      if vim.fn.filereadable(marker_path) == 1 then
        table.insert(found_markers, project_type .. " (" .. marker .. ")")
      end
    end
  end
  
  if #found_markers > 0 then
    print("  Found markers: " .. table.concat(found_markers, ", "))
  else
    print("  No project markers found in current directory")
  end
end

return M