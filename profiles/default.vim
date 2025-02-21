
" Configuración básica
set number           " Mostrar números de línea
set relativenumber   " Números relativos para facilitar movimientos
set wrap             " Ajustar texto al ancho de la ventana
set autoindent       " Mantener la indentación de la línea anterior
set smartindent      " Indentación inteligente
set tabstop=4        " Ancho de tabulación en 4 espacios
set shiftwidth=4     " Espacios usados para la indentación automática
set expandtab        " Convertir tabs en espacios
set clipboard+=unnamedplus " Compartir portapapeles del sistema

" Habilitar colores
set termguicolors

" Configuración de búsqueda
set ignorecase       " Ignorar mayúsculas/minúsculas al buscar
set smartcase        " Buscar con mayúsculas si se incluyen en el término
set hlsearch         " Resaltar coincidencias

" Plugins básicos
call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-tree/nvim-tree.lua'       " Explorador de archivos
Plug 'nvim-lualine/lualine.nvim'     " Barra de estado
Plug 'tpope/vim-fugitive'            " Git integrado
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Resaltado de sintaxis
call plug#end()

" Configuración del explorador de archivos
lua << EOF
require'nvim-tree'.setup {
  view = {
    width = 30,
    side = "left",
  },
}
EOF

" Configuración de lualine
lua << EOF
require('lualine').setup {
  options = {
    theme = 'gruvbox',
  },
}
EOF

" Mapeos básicos
nnoremap <leader>e :NvimTreeToggle<CR>  " Alternar el explorador de archivos
nnoremap <leader>w :w<CR>              " Guardar archivo
nnoremap <leader>q :q<CR>              " Salir de Neovim
