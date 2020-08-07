set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

"------------------
" Code Completions
"------------------
Bundle 'Shougo/neocomplcache'
Bundle 'mattn/emmet-vim'
Bundle 'Raimondi/delimitMate'
Bundle 'ervandew/supertab'
" snippets
Bundle 'garbas/vim-snipmate'
Bundle 'honza/vim-snippets'
"------ snipmate dependencies -------
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'

"-----------------
" Fast navigation
"-----------------
Bundle 'Lokaltog/vim-easymotion'

"--------------
" Fast editing
"--------------
Bundle 'sjl/gundo.vim'
Bundle 'nathanaelkane/vim-indent-guides'

"--------------
" IDE features
"--------------
Bundle 'scrooloose/nerdtree'
" Bundle 'scrooloose/syntastic' " too slow
Bundle 'bronson/vim-trailing-whitespace'

"------- web frontend ----------
Bundle 'othree/html5.vim'
Bundle 'leafgarland/typescript-vim'
Bundle 'peitalin/vim-jsx-typescript'


" Bundle 'tpope/vim-haml'
Bundle 'pangloss/vim-javascript'
Bundle 'kchmck/vim-coffee-script'
Bundle 'nono/jquery.vim'

"------- markup language -------
Bundle 'tpope/vim-markdown'

"------- Go ----------
Bundle 'fatih/vim-go'

"------- FPs ------
Bundle 'kien/rainbow_parentheses.vim'

"--------------
" Color Schemes
"--------------
Bundle 'rickharris/vim-blackboard'
Bundle 'tpope/vim-vividchalk'
Bundle 'Lokaltog/vim-distinguished'

filetype plugin indent on     " required!
