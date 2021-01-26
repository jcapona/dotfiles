if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" syntax
Plug 'sheerun/vim-polyglot'
"Plug 'HerringtonDarkholme/yats.vim'
Plug 'leafgarland/typescript-vim'
Plug 'yuezk/vim-js'

" Nerdtree improvements
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'vwxyutarooo/nerdtree-devicons-syntax'



" status bar
"This plugin provides ALE indicator for the lightline vim plugin.
"Plug 'maximbaz/lightline-ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"A light and configurable statusline/tabline plugin for Vim
Plug 'itchyny/lightline.vim'

" Themes
Plug 'morhetz/gruvbox'
Plug 'shinchu/lightline-gruvbox.vim'

" Tree
Plug 'scrooloose/nerdtree'

" typing
"Insert or delete brackets, parens, quotes in pair.
Plug 'jiangmiao/auto-pairs'
"Autoclose html tags
Plug 'alvan/vim-closetag'
"Surround.vim is all about 'surroundings': parentheses, brackets, quotes, XML tags, and more
Plug 'tpope/vim-surround'

" autocomplete
"Plug 'sirver/ultisnips'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" IDE
Plug 'editorconfig/editorconfig-vim'
"fzf is a general-purpose command-line fuzzy finder.
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
"Multiple cursors
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
"Signify (or just Sy) uses the sign column to indicate added, modified and removed lines in a file that is managed by a version control system (VCS).
Plug 'mhinz/vim-signify'
"Display thin vertical lines at each indentation level for code indented with spaces
Plug 'yggdroot/indentline'


call plug#end()
