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
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "elixir", "lua", "javascript", "php", "markdown", "markdown_inline", "http" },
          highlight = { enable = true },
          fold = {
            enable = false,
          }
        })
      end,
    },

    -- Depuración
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },


    -- plugins.lua - Parte relevante para Telescope
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git", "dist" },
            mappings = {
              i = { ["<C-k>"] = "move_selection_previous", ["<C-j>"] = "move_selection_next" },
              n = {
                ["<CR>"] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_next,
                ["<C-x>"] = false, -- Remove default mapping if needed
              },
            },
          },
          pickers = {
            find_files = {
              hidden = true
            },
            live_grep = {
              additional_args = function() return { "--hidden" } end
            },
            git_status = {
              mappings = {
                i = {
                  ["<CR>"] = require('telescope.actions').git_staging_toggle,
                },
              },
            },
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
    {
      "nvim-tree/nvim-web-devicons",
      config = function()
        require("nvim-web-devicons").set_icon({
          folder = {
            icon = "",  -- Icono de carpeta por defecto
            color = "#FFD700",  -- Amarillo/Dorado
            name = "Folder",
          },
          folder_open = {
            icon = "",
            color = "#FFA500", -- Naranja cuando está abierta
            name = "FolderOpen",
          },
        })
      end,
    },

    -- Tema Gruvbox
    {
      "tanvirtin/monokai.nvim",
      config = function()
        vim.cmd("colorscheme monokai") -- Activar Monokai automáticamente
      end,
    },
    -- IA (Avante.nvim)
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      lazy = false,
      version = false,
      build = "make",
      auto_suggestions_provider = "copilot",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "echasnovski/mini.pick",
        "nvim-telescope/telescope.nvim",
        "hrsh7th/nvim-cmp",
        "ibhagwan/fzf-lua",
        "nvim-tree/nvim-web-devicons",
        "github/copilot.vim",
        {
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              use_absolute_path = true,
            },
          },
        },
        {
          "MeanderingProgrammer/render-markdown.nvim",
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
      opts = {
        provider = "groq",
        vendors = {
          groq = {
            __inherited_from = "openai",
            api_key_name = "GROQ_API_KEY",
            endpoint = "https://api.groq.com/openai/v1/",
            model = "deepseek-r1-distill-qwen-32b",
          },
          ollama = {
            __inherited_from = "openai",
            endpoint = "http://127.0.0.1:11434/v1",
            model = "openthinker",
            api_key_name = "",
          },
        },
      },
    },
    -- Explorador de directorios
    -- nvimtree directorios
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("nvim-tree").setup({
          filters = {
            dotfiles = false,  -- Mostrar archivos ocultos
            custom = {},       -- No ocultar otros archivos
          },
          git = {
            ignore = false,    -- No ocultar archivos de .gitignore
          },
          view = { width = 50, side = "left" },
          renderer = { 
            icons = {
              show = {
                file = true,
                folder = true,
                folder_arrow = true,
              }
            }
          },
          actions = {
            open_file = {
              quit_on_open = true
            }
          },
          sync_root_with_cwd = true,  -- Sincroniza el árbol con el directorio actual
          respect_buf_cwd = true,  -- Respeta el directorio donde se abre Neovim
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
            separator_style = "slam",
            diagnostics = "nvim_lsp",
            show_buffer_close_icons = false,
            show_close_icon = false,
            always_show_bufferline = true,
            enforce_regular_tabs = false,
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
    -- mejorar mensajes
    {
      "rcarriga/nvim-notify",
      config = function()
        vim.notify = require("notify")
      end,
    },
    -- markdown
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && npm install",
      config = function()
        vim.g.mkdp_auto_start = 1
      end,
    },
    -- Git Signs (resaltado de cambios en el código)
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
          },
          numhl = true,
          current_line_blame = true,
          sign_priority = 6,
        })
      end,
    },

    -- Barra de estado (Lualine)
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = {
            icons_enabled = true,
            theme = "gruvbox_dark",
            component_separators = "|",
            section_separators = "",
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch" },
            lualine_c = { "%f" },
            lualine_x = {
              -- Permisos del archivo
              {
                function()
                  local file = vim.fn.expand("%:p")
                  if file == "" or file == nil then
                    return "No File"
                  else
                    return vim.fn.getfperm(file)
                  end
                end,
                color = function()
                  local file = vim.fn.expand("%:p")
                  if file == "" or file == nil then
                    return { fg = "#36454F", bg = "#0099ff", gui = "bold" }
                  else
                    local permissions = vim.fn.getfperm(file)
                    local owner_permissions = permissions:sub(1, 3)
                    local bg_color = owner_permissions == "rwx" and "#00ff00" or "#0099ff"
                    return { fg = "#36454F", bg = bg_color, gui = "bold" }
                  end
                end,
                separator = "|",
                padding = 1,
              },
              -- Hostname
              {
                function()
                  return vim.fn.systemlist("hostname")[1]
                end,
                color = function()
                  local hostname = vim.fn.systemlist("hostname")[1]
                  local last_char = hostname:sub(-1)
                  local bg_color = "#A6AAF1" -- Color por defecto

                  if last_char == "1" then
                    bg_color = "#0DFFAE"
                  elseif last_char == "2" then
                    bg_color = "#FF6200"
                  elseif last_char == "3" then
                    bg_color = "#DBF227"
                  end

                  return { fg = "#36454F", bg = bg_color, gui = "bold" }
                end,
                separator = "|",
                padding = 1,
              },
              "encoding",
              "fileformat",
              "filetype",
            },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
        })
      end,
    },
    -- NVIM REST
    {
      "rest-nvim/rest.nvim",
      dependencies = { "nvim-lua/plenary.nvim" }, -- Dependencia obligatoria
      config = function()
        require("rest-nvim").setup({
          result_split_horizontal = false,  -- Mostrar respuesta en un panel vertical
          skip_ssl_verification = false,    -- Verificar SSL en peticiones HTTPS
          encode_url = true,                -- Codificar URLs automáticamente
          highlight = { enabled = true },   -- Resaltar respuesta en JSON
        })
      end,
    },
   -- Git
    {
      "tpope/vim-fugitive"
    },
    {
      "sindrets/diffview.nvim",
      dependencies = {"nvim-lua/plenary.nvim"}, -- Asegúrate de que plenary.nvim está incluido
      config = function()
        require('diffview').setup({
          use_icons = true,  -- Usa íconos si tienes nvim-web-devicons instalado
          enhanced_diff_hl = true, -- Mejora el resaltado de diffs
          key_bindings = {
            view = {
              ["<tab>"] = function(bufnr) require("diffview.actions").select_next_entry() end, -- Cambia a la entrada siguiente con tab
              ["<s-tab>"] = function(bufnr) require("diffview.actions").select_prev_entry() end, -- Cambia a la entrada anterior con shift+tab
            },
            file_panel = {
              ["j"] = function() require("diffview.actions").next_entry() end, -- Siguiente archivo
              ["k"] = function() require("diffview.actions").prev_entry() end, -- Archivo anterior
            }
          }
        })
      end
    },
  -- emmet
   -- Plugins recomendados para desarrollo Frontend
    -- Añade estos plugins a tu archivo plugins.lua existente

    -- TypeScript y React
    {
      "jose-elias-alvarez/typescript.nvim",
      config = function()
        require("typescript").setup({
          server = {
            on_attach = function(client, bufnr)
              -- Deshabilitar el formateo de TSServer, ya que usaremos Prettier
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end,
          }
        })
      end,
    },

    -- TailwindCSS
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "b0o/schemastore.nvim", -- Esquemas JSON para autocompletado
      }
    },

    -- Auto-cierre de etiquetas para HTML/JSX
    {
      "windwp/nvim-ts-autotag",
      dependencies = "nvim-treesitter/nvim-treesitter",
      config = function()
        require("nvim-ts-autotag").setup()
      end,
    },

    -- Formateo con Prettier
    {
      "MunifTanjim/prettier.nvim",
      dependencies = { "jose-elias-alvarez/null-ls.nvim" },
      config = function()
        require("prettier").setup({
          bin = 'prettier',
          filetypes = {
            "css", "scss", "less",
            "javascript", "javascriptreact", "typescript", "typescriptreact",
            "json", "jsonc", "yaml", "html", "vue", "graphql"
          },
          cli_options = {
            single_quote = true,
            trailing_comma = "all",
          }
        })
      end,
    },

    -- CSS Color Preview (visualización de colores en archivos CSS)
    {
      "NvChad/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup({
          filetypes = { "css", "scss", "html", "javascript", "typescript", "jsx", "tsx", "vue" },
          user_default_options = {
            RGB = true,           -- #RGB hex codes
            RRGGBB = true,        -- #RRGGBB hex codes
            names = true,         -- "Name" codes like Blue
            RRGGBBAA = true,      -- #RRGGBBAA hex codes
            rgb_fn = true,        -- CSS rgb() and rgba() functions
            hsl_fn = true,        -- CSS hsl() and hsla() functions
            mode = "background",  -- Set the display mode
          }
        })
      end,
    },

    -- Live Server para HTML
    {
      "turbio/bracey.vim",
      build = "npm install --prefix server",
      config = function()
        vim.g.bracey_auto_start_browser = 1
        vim.g.bracey_refresh_on_save = 1
      end,
    },

    -- Snippets para React
    {
      "dsznajder/vscode-react-javascript-snippets",
      build = "yarn install --frozen-lockfile && yarn compile",
    },

    -- Soporte mejorado para GraphQL
    {
      "jparise/vim-graphql",
    },

    -- Soporte para Styled Components
    {
      "styled-components/vim-styled-components",
    },

    -- Emmet mejorado para JSX/React
    {
      "mattn/emmet-vim",
      config = function()
        vim.g.user_emmet_settings = {
          javascript = {
            extends = 'jsx',
          },
          typescript = {
            extends = 'tsx',
          }
        }
        -- Activar Emmet solo en estos tipos de archivo
        vim.g.user_emmet_install_global = 0
        vim.cmd [[
          autocmd FileType html,css,javascript,javascriptreact,typescript,typescriptreact EmmetInstall
        ]]
      end,
    },

    -- Soporte para testing (Jest)
    {
      "vim-test/vim-test",
      config = function()
        vim.g['test#javascript#jest#executable'] = 'npm test --'
        vim.g['test#strategy'] = 'neovim'
      end,
    },

    -- Complementar información de React en statusline
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          sections = {
            lualine_c = {
              {
                function()
                  -- Detectar componente de React actual
                  local filename = vim.fn.expand('%:t')
                  local filetype = vim.bo.filetype
                  if filetype == "typescriptreact" or filetype == "javascriptreact" then
                    local name = filename:match("(.+)%..+$")
                    if name then
                      return "React: " .. name
                    end
                  end
                  return filename
                end,
              }
            }
          }
        })
      end,
    },

    -- Integración con NPM (run scripts desde nvim)
    {
      "vuki656/package-info.nvim",
      dependencies = { "MunifTanjim/nui.nvim" },
      config = function()
        require("package-info").setup()
      end,
    },

    -- Comentarios JSX mejorados
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      config = function()
        require('ts_context_commentstring').setup({
          enable_autocmd = false,
        })
        -- Configurar Comment.nvim para usar context commentstring
        require('Comment').setup({
          pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
        })
      end,
    }, 
    -- Para mejorar soporte de CSS en HTML
    {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require('colorizer').setup({'html', 'css', 'javascript'}, {
          css = true,
          css_fn = true,
          mode = 'background'
        })
      end
    },

    -- Para un mejor resaltado de sintaxis de CSS
    {
      "othree/csscomplete.vim",
      config = function()
        vim.cmd('autocmd FileType css,scss,less,html setlocal omnifunc=csscomplete#CompleteCSS')
      end
    },
    },
  {
    rocks = {
      hererocks = true, -- Habilita la instalación automática de hererocks
    },
 })
