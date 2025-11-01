local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.wrap = true
opt.showmatch = true
opt.foldmethod = 'marker'
opt.splitright = true
opt.splitbelow = true
opt.conceallevel = 0
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.guifont = "JetBrainsMono Nerd Font:h10"

-- Sistema
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.fileencoding = 'utf-8'
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Rendimiento
opt.updatetime = 300
opt.timeoutlen = 500
opt.lazyredraw = true

-- Evitar mensaje "Press ENTER to continue"
opt.cmdheight = 1           -- Altura de la línea de comandos
opt.shortmess:append("c")   -- No mostrar mensajes de autocompletado
opt.shortmess:append("I")   -- No mostrar intro message
opt.shortmess:append("W")   -- No mostrar "written" al guardar
opt.shortmess:append("a")   -- Usar abreviaciones en mensajes