call plug#begin()

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

let g:netrw_banner=0

set background=dark
"colorscheme retrobox

" https://raw.githubusercontent.com/jnurmine/Zenburn/refs/heads/master/colors/zenburn.vim
" Put it under ~/.vim/colors 
colorscheme zenburn

set number
set relativenumber
set cursorline
set visualbell
set scrolloff=8

let mapleader = " "

map <leader>f :FZF<CR>

