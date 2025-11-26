return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Go to definition"
        vim.keymap.set("n", "gd", function()
          local word = vim.fn.expand("<cword>")
          local ok, _ = pcall(require("telescope.builtin").lsp_definitions, { reuse_win = true })
          if not ok then
            print("LSP definition not available for: " .. word .. ", searching with grep...")
            vim.cmd("Telescope grep_string search=" .. word)
          end
        end, opts)

        opts.desc = "Go to definition (alternative)"
        vim.keymap.set("n", "<C-]>", function()
          local word = vim.fn.expand("<cword>")
          local ok, _ = pcall(require("telescope.builtin").lsp_definitions, { reuse_win = true })
          if not ok then
            print("LSP definition not available for: " .. word .. ", searching with grep...")
            vim.cmd("Telescope grep_string search=" .. word)
          end
        end, opts)

        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gr", function()
          local word = vim.fn.expand("<cword>")
          local ok, _ = pcall(require("telescope.builtin").lsp_references)
          if not ok then
            print("LSP references not available for: " .. word .. ", searching with grep...")
            vim.cmd("Telescope grep_string search=" .. word)
          end
        end, opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", opts)

        opts.desc = "See available code actions"
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        vim.keymap.set("n", "<leader>D", function()
          vim.diagnostic.setloclist()
        end, opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>", opts)
      end,
    })

    vim.lsp.config('*', {
      capabilities = capabilities,
      root_markers = { '.git' },
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME,
              "${3rd}/luv/library",
            },
          },
        },
      },
    })

    vim.lsp.config('emmet_ls', {
      filetypes = { "html", "css", "javascriptreact", "typescriptreact", "twig" },
    })

    vim.lsp.config('elixirls', {
      cmd = { vim.fn.expand("~/.local/bin/elixir-ls") },
      settings = {
        elixirLS = {
          dialyzerEnabled = true,
          fetchDeps = true,
          suggestSpecs = true,
          enableTestLenses = true,
          signatureAfterComplete = true,
          autoBuild = true,
        },
      },
    })

    local servers = {
      "lua_ls",
      "ts_ls",
      "html",
      "cssls",
      "jsonls",
      "pyright",
      "rust_analyzer",
      "clangd",
      "elixirls",
      "jdtls",
      "emmet_ls",
      "sqlls",
      "intelephense",
    }

    for _, server in ipairs(servers) do
      vim.lsp.enable(server)
    end
  end,
}
