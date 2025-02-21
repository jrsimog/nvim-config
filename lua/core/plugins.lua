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
        ensure_installed = { "lua_ls", "tsserver", "html", "cssls", "phpactor" },
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
})
