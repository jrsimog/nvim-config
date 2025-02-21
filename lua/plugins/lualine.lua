

-- lua/plugins/init.lua
-- Función auxiliar para configurar plugins de manera segura
  local function setup_plugin(name, config)
    local status_ok, plugin = pcall(require, name)
    if status_ok then
      plugin.setup(config or {})
    else
      vim.notify('Plugin ' .. name .. ' no encontrado', vim.log.levels.WARN)
    end
  end

  -- Configuraciones de Lualine
  setup_plugin('lualine', {
    options = {
      theme = 'material',
      icons_enabled = true,
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    }
  })

  -- Configuración de BufferLine
  setup_plugin('bufferline', {
    options = {
      separator_style = "thin"
    }
  })

  -- Configuración de nvim-tree
  setup_plugin('nvim-tree', {
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true
    },
  })

  -- Configuración de Comment.nvim
  setup_plugin('Comment')

  -- Configuración de Treesitter
  setup_plugin('nvim-treesitter.configs', {
    ensure_installed = { "lua", "vim", "javascript", "typescript", "php" },
    highlight = {
      enable = true,
    },
  })

  -- Configuración de Gitsigns
  setup_plugin('gitsigns')

  -- Configuración de indent-blankline v3
  setup_plugin('ibl', {
    scope = {
      enabled = true,
      show_start = true,
      show_end = true,
    },
    indent = {
      char = "│",
    },
  })

  -- Configuración de nvim-ufo
  setup_plugin('ufo')

-- Configuración de Project.nvim
setup_plugin('project_nvim', {
    detection_methods = { 'lsp', 'pattern' },
    patterns = { '.git', 'composer.json', 'Makefile', 'package.json' },
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = 'global',
    datapath = vim.fn.stdpath("data"),
})

-- Configuración personalizada de Alpha Dashboard
local alpha_status_ok, alpha = pcall(require, "alpha")
if alpha_status_ok then
    local dashboard = require("alpha.themes.dashboard")

    -- Encabezado personalizado
    dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
        string.format("[ 󰅐 %s ]", os.date("%Y-%m-%d %H:%M:%S")),
        string.format("[ 󰊤 @%s ]", "jrsimog"),
    }

    -- Función para obtener los proyectos recientes con iconos mejorados
    local function get_recent_projects()
        local project = require('project_nvim')
        local recent_projects = project.get_recent_projects()
        local buttons = {}

        -- Limitamos a 5 proyectos recientes
        for i, path in ipairs(recent_projects) do
            if i > 5 then break end
            -- Obtener solo el nombre de la carpeta del proyecto
            local project_name = vim.fn.fnamemodify(path, ':t')
            -- Determinar el icono usando nvim-web-devicons
            local icon = require('nvim-web-devicons').get_icon(project_name, '', { default = true })

            -- Crear el botón con el formato deseado
            local btn = dashboard.button(
                tostring(i),
                string.format("%s  %-30s", icon, project_name),
                string.format(":cd %s | Telescope find_files<CR>", path)
            )
            table.insert(buttons, btn)
        end

        return buttons
    end

    -- Botones personalizados con iconos mejorados
    dashboard.section.buttons.val = {
        dashboard.button('e', '  Nuevo archivo', ':ene <BAR> startinsert<CR>'),
        dashboard.button('f', '󰈞  Buscar archivo', ':Telescope find_files<CR>'),
        dashboard.button('r', '  Archivos recientes', ':Telescope oldfiles<CR>'),
        dashboard.button('p', '  Proyectos', ':Telescope projects<CR>'),
        dashboard.button('s', '  Configuraciones', ':e $MYVIMRC<CR>'),
        dashboard.button('u', '  Actualizar plugins', ':PlugUpdate<CR>'),
        dashboard.button('q', '  Salir', ':qa<CR>'),
    }

    -- Añadir sección de proyectos recientes
    dashboard.section.projects = {
        type = "group",
        val = get_recent_projects(),
        opts = {
            spacing = 1,
            position = "center",
        },
    }

    -- Pie de página personalizado
    local footer_text = "⚡ Neovim - @jrsimog"
    if vim.g.start_time then
        footer_text = footer_text .. string.format(
            " (Cargado en %.3f ms)",
            vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time)) * 1000
        )
    end
    dashboard.section.footer.val = footer_text

    -- Configurar el orden de las secciones
    dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        { type = "text", val = "📂 Proyectos Recientes:", opts = { position = "center" } },
        { type = "padding", val = 1 },
        dashboard.section.projects,
        { type = "padding", val = 1 },
        dashboard.section.footer,
    }

    -- Aplicar configuración
    alpha.setup(dashboard.config)
end
  -- Configuración de Telescope
  setup_plugin('telescope')

  -- Configuración de Avante
  setup_plugin('avante', {
    provider = "deepseek",
    auto_suggestions_provider = "deepseek",
    deepseek = {
      endpoint = "https://api.deepseek.com/v1",
      model = "deepseek-coder-33b-instruct",
      temperature = 0.7,
      max_tokens = 4096,
    },
    behaviour = {
      auto_suggestions = true,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
    },
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
    },
    windows = {
      position = "right",
      wrap = true,
      width = 30,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = true,
      },
    },
  })

  -- Configuración de img-clip
  setup_plugin('img-clip', {
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)"
      }
    }
  })

  -- Configuración de render-markdown
  setup_plugin('render-markdown', {
    latex = {
      enabled = false
    }
  })
-- lua/plugins/init.lua
-- Función auxiliar para configurar plugins de manera segura
  local function setup_plugin(name, config)
    local status_ok, plugin = pcall(require, name)
    if status_ok then
      plugin.setup(config or {})
    else
      vim.notify('Plugin ' .. name .. ' no encontrado', vim.log.levels.WARN)
    end
  end

  -- Configuraciones de Lualine
  setup_plugin('lualine', {
    options = {
      theme = 'material',
      icons_enabled = true,
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    }
  })

  -- Configuración de BufferLine
  setup_plugin('bufferline', {
    options = {
      separator_style = "thin"
    }
  })

  -- Configuración de nvim-tree
  setup_plugin('nvim-tree', {
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true
    },
  })

  -- Configuración de Comment.nvim
  setup_plugin('Comment')

  -- Configuración de Treesitter
  setup_plugin('nvim-treesitter.configs', {
    ensure_installed = { "lua", "vim", "javascript", "typescript", "php" },
    highlight = {
      enable = true,
    },
  })

  -- Configuración de Gitsigns
  setup_plugin('gitsigns')

  -- Configuración de indent-blankline v3
  setup_plugin('ibl', {
    scope = {
      enabled = true,
      show_start = true,
      show_end = true,
    },
    indent = {
      char = "│",
    },
  })

  -- Configuración de nvim-ufo
  setup_plugin('ufo')

-- Configuración de Project.nvim
setup_plugin('project_nvim', {
    detection_methods = { 'lsp', 'pattern' },
    patterns = { '.git', 'composer.json', 'Makefile', 'package.json' },
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = 'global',
    datapath = vim.fn.stdpath("data"),
})

-- Configuración personalizada de Alpha Dashboard
local alpha_status_ok, alpha = pcall(require, "alpha")
if alpha_status_ok then
    local dashboard = require("alpha.themes.dashboard")

    -- Encabezado personalizado
    dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
        string.format("[ 󰅐 %s ]", os.date("%Y-%m-%d %H:%M:%S")),
        string.format("[ 󰊤 @%s ]", "jrsimog"),
    }

    -- Función para obtener los proyectos recientes con iconos mejorados
    local function get_recent_projects()
        local project = require('project_nvim')
        local recent_projects = project.get_recent_projects()
        local buttons = {}

        -- Limitamos a 5 proyectos recientes
        for i, path in ipairs(recent_projects) do
            if i > 5 then break end
            -- Obtener solo el nombre de la carpeta del proyecto
            local project_name = vim.fn.fnamemodify(path, ':t')
            -- Determinar el icono usando nvim-web-devicons
            local icon = require('nvim-web-devicons').get_icon(project_name, '', { default = true })

            -- Crear el botón con el formato deseado
            local btn = dashboard.button(
                tostring(i),
                string.format("%s  %-30s", icon, project_name),
                string.format(":cd %s | Telescope find_files<CR>", path)
            )
            table.insert(buttons, btn)
        end

        return buttons
    end

    -- Botones personalizados con iconos mejorados
    dashboard.section.buttons.val = {
        dashboard.button('e', '  Nuevo archivo', ':ene <BAR> startinsert<CR>'),
        dashboard.button('f', '󰈞  Buscar archivo', ':Telescope find_files<CR>'),
        dashboard.button('r', '  Archivos recientes', ':Telescope oldfiles<CR>'),
        dashboard.button('p', '  Proyectos', ':Telescope projects<CR>'),
        dashboard.button('s', '  Configuraciones', ':e $MYVIMRC<CR>'),
        dashboard.button('u', '  Actualizar plugins', ':PlugUpdate<CR>'),
        dashboard.button('q', '  Salir', ':qa<CR>'),
    }

    -- Añadir sección de proyectos recientes
    dashboard.section.projects = {
        type = "group",
        val = get_recent_projects(),
        opts = {
            spacing = 1,
            position = "center",
        },
    }

    -- Pie de página personalizado
    local footer_text = "⚡ Neovim - @jrsimog"
    if vim.g.start_time then
        footer_text = footer_text .. string.format(
            " (Cargado en %.3f ms)",
            vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time)) * 1000
        )
    end
    dashboard.section.footer.val = footer_text

    -- Configurar el orden de las secciones
    dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        { type = "text", val = "📂 Proyectos Recientes:", opts = { position = "center" } },
        { type = "padding", val = 1 },
        dashboard.section.projects,
        { type = "padding", val = 1 },
        dashboard.section.footer,
    }

    -- Aplicar configuración
    alpha.setup(dashboard.config)
end
  -- Configuración de Telescope
  setup_plugin('telescope')

  -- Configuración de Avante
  setup_plugin('avante', {
    provider = "deepseek",
    auto_suggestions_provider = "deepseek",
    deepseek = {
      endpoint = "https://api.deepseek.com/v1",
      model = "deepseek-coder-33b-instruct",
      temperature = 0.7,
      max_tokens = 4096,
    },
    behaviour = {
      auto_suggestions = true,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
    },
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
    },
    windows = {
      position = "right",
      wrap = true,
      width = 30,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = true,
      },
    },
  })

  -- Configuración de img-clip
  setup_plugin('img-clip', {
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)"
      }
    }
  })

  -- Configuración de render-markdown
  setup_plugin('render-markdown', {
    latex = {
      enabled = false
    }
  })
