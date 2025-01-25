syntax enable


inoremap jj <esc>

set tabstop=4
set softtabstop=4
set expandtab


set number

filetype indent on

set incsearch "incremental search and regex view
set hlsearch "highlight searches

lua require('init')

nnoremap <Space>f <cmd>Telescope find_files<cr>
nnoremap <Space>g <cmd>Telescope live_grep<cr>
nnoremap <Space>b <cmd>Telescope buffers<cr>
