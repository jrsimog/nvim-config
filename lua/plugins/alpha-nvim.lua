-- lua/plugins/alpha.lua

local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local dashboard = require("alpha.themes.dashboard")

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

local function get_recent_projects()
    local project = require('project_nvim')
    local recent_projects = project.get_recent_projects()
    local buttons = {}

    for i, path in ipairs(recent_projects) do
        if i > 5 then break end
        local project_name = vim.fn.fnamemodify(path, ':t')
        local icon = require('nvim-web-devicons').get_icon(project_name, '', { default = true })

        local btn = dashboard.button(
            tostring(i),
            string.format("%s  %-30s", icon, project_name),
            string.format(":cd %s | Telescope find_files<CR>", path)
        )
        table.insert(buttons, btn)
    end

    return buttons
end

dashboard.section.buttons.val = {
    dashboard.button('e', '  Nuevo archivo', ':ene <BAR> startinsert<CR>'),
    dashboard.button('f', '󰈞  Buscar archivo', ':Telescope find_files<CR>'),
    dashboard.button('r', '  Archivos recientes', ':Telescope oldfiles<CR>'),
    dashboard.button('p', '  Proyectos', ':Telescope projects<CR>'),
    dashboard.button('s', '  Configuraciones', ':e $MYVIMRC<CR>'),
    dashboard.button('u', '  Actualizar plugins', ':PlugUpdate<CR>'),
    dashboard.button('q', '  Salir', ':qa<CR>'),
}

dashboard.section.projects = {
    type = "group",
    val = get_recent_projects(),
    opts = {
        spacing = 1,
        position = "center",
    },
}

local footer_text = "⚡ Neovim - @jrsimog"
if vim.g.start_time then
    footer_text = footer_text .. string.format(
        " (Cargado en %.3f ms)",
        vim.fn.reltimefloat(vim.fn.reltime(vim.g.start_time)) * 1000
    )
end
dashboard.section.footer.val = footer_text

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

alpha.setup(dashboard.config)
