return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
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
      },
      automatic_installation = true,
    })
  end,
}
