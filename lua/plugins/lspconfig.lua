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

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Go to definition"
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

        opts.desc = "Go to definition (leader)"
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

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
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
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
      settings = {
        elixirLS = {
          dialyzerEnabled = true,
          fetchDeps = false,
          suggestSpecs = true,
          enableTestLenses = true,
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
      "gopls",
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
