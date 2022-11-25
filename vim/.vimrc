call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/goyo.vim'
Plug 'pangloss/vim-javascript'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

let g:airline_powerline_fonts = 1
let g:netrw_banner = 0
let g:netrw_liststyle = 3

"set textwidth=80
"set background=dark
set number
set relativenumber
set scrolloff=8
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set visualbell

colorscheme peachpuff

" --- Conqueror of Completion --
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()

" use <tab> and <shift-tab> for navigating forward & backward within
" completion items
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use <cr> for validating the selected completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" change leader to COMMA
let mapleader = ","

" ,f triggers fzf
map <leader>f :FZF<CR>

