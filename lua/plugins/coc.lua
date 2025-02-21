-- lua/plugins/coc.lua
vim.cmd([[
  " Coc.nvim configuration
  let g:coc_global_extensions = [
    \ 'coc-pylsp',
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-yaml',
    \ 'coc-sh',
    \ 'coc-snippets',
    \ 'coc-prettier',
    \ 'coc-eslint'
  \ ]
]])

-- Key mappings for coc.nvim
vim.api.nvim_set_keymap('n', '<leader>rn', '<Plug>(coc-rename)', {})
vim.api.nvim_set_keymap('n', '<leader>ca', '<Plug>(coc-codeaction)', {})
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', {})
vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {})
vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)', {})
vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)', {})
