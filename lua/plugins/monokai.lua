return {
  "tanvirtin/monokai.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    require("monokai").setup({
      palette = require("monokai").pro,
    })

    vim.cmd("colorscheme monokai")

    local function apply_custom_highlights()
      vim.cmd([[
        highlight DiffAdd    guibg=#294436 gui=none
        highlight DiffDelete guibg=#402b2b gui=none
        highlight DiffChange guibg=#1c4881 gui=none
        highlight DiffText   guibg=#265478 gui=none
      ]])

      vim.cmd([[
        highlight DiagnosticError guifg=#ff6b6b gui=bold
        highlight DiagnosticWarn  guifg=#feca57 gui=bold
        highlight DiagnosticInfo  guifg=#48cae4 gui=bold
        highlight DiagnosticHint  guifg=#06d6a0 gui=bold
      ]])
    end

    apply_custom_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = apply_custom_highlights,
    })

    vim.o.colorcolumn = "80,120"
  end,
}
