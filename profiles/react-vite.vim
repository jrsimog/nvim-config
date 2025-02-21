
" Configuraciones específicas para ReactJS, Tailwind y Vite

" Plugins necesarios
call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'windwp/nvim-ts-autotag' " Para cerrar etiquetas JSX/HTML automáticamente
Plug 'norcalli/nvim-colorizer.lua' " Para ver colores en Tailwind
Plug 'jose-elias-alvarez/null-ls.nvim' " Soporte de linting/formateo
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

" Configuración de Treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "javascript", "typescript", "tsx", "html", "css" },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}
EOF

" Configuración de Null-ls para Prettier y ESLint
lua << EOF
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
  },
})
EOF

" Configuración de COC para React y Tailwind
let g:coc_global_extensions = [
\ 'coc-tsserver',
\ 'coc-eslint',
\ 'coc-prettier',
\ 'coc-tailwindcss'
\]

" Atajos adicionales específicos
nnoremap <leader>r :CocCommand eslint.executeAutofix<CR>
nnoremap <leader>p :CocCommand prettier.formatFile<CR>
