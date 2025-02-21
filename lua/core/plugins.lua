-- plugins.lua - Gestión de plugins con Lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- LSP y Autocompletado
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "lua_ls", 
          "ts_ls",
          "html",
          "cssls",
          "intelephense",
          "elixirls",
        },
        automatic_installation = true,
      })

      require("lspconfig").lua_ls.setup({})
    end,
  },

  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "saadparwaiz1/cmp_luasnip", "L3MON4D3/LuaSnip" } },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Depuración
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },

  -- Explorador de archivos
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Buscador y Navegación
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "dist" },
          mappings = {
            i = { ["<C-k>"] = "move_selection_previous", ["<C-j>"] = "move_selection_next" },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep = { additional_args = function() return { "--hidden" } end },
        },
      })
    end,
  },


  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Formateo y Linters
  { "jose-elias-alvarez/null-ls.nvim" },
  { "MunifTanjim/prettier.nvim" },

  -- Comentar código
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },

  -- Auto-cierre de paréntesis
  { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup() end },

  -- Temas y UI
  { "folke/tokyonight.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- Tema Gruvbox
  { "morhetz/gruvbox" },


  -- IA (Avante.nvim)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
      provider = "openai",
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4",
        timeout = 30000,
        temperature = 0,
        max_tokens = 4096,
        reasoning_effort = "high",
      },
    },
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
    },
  },
  -- nvimtree directorios
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { 
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
            }
          }
        },
        actions = { open_file = { quit_on_open = true } },
      })
    end,
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          separator_style = "slant",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = true,
        },
      })
    end,
  },
  ---- inicio
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Encabezado del dashboard
      dashboard.section.header.val = {
        "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██║   ██║██║████╗ ████║",
        "██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }

      -- Botones personalizados (rescatados de tu backup)
      dashboard.section.buttons.val = {
        dashboard.button("e", "📄  Nuevo archivo", ":ene <BAR> startinsert<CR>"),
        dashboard.button("f", "🔍  Buscar archivo", ":Telescope find_files<CR>"),
        dashboard.button("r", "📋  Archivos recientes", ":Telescope oldfiles<CR>"),
        dashboard.button("p", "📂  Proyectos", ":Telescope projects<CR>"),
        dashboard.button("s", "⚙️  Configuración", ":e $MYVIMRC<CR>"),
        dashboard.button("u", "🔄  Actualizar plugins", ":Lazy sync<CR>"),
        dashboard.button("q", "🚪  Salir", ":qa<CR>"),
      }

      -- Pie de página
      dashboard.section.footer.val = "🚀 Configuración restaurada desde backup"

      -- Configurar layout del dashboard
      alpha.setup(dashboard.opts)
    end,
  },
  -- proyectos
  {
    "ahmedkhalf/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "package.json", "mix.exs" },
      })
      require("telescope").load_extension("projects")
    end,
  },



})
