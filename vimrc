" vim: foldmethod=marker ts=2 sts=2 sw=2 fdl=0

let s:cache_dir = '~/.vimcache'

" initialize default settings
let s:settings = {}
let s:settings.default_indent = 4
let s:settings.enable_cursorcolumn = 0
let s:settings.colorscheme = 'seoul256'

" setup
set nocompatible
set all& "reset everything to their defaults

" functions {{{
function! s:get_cache_dir(suffix)
  return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction

function! EnsureExists(path)
  if !isdirectory(expand(a:path))
    call mkdir(expand(a:path))
  endif
endfunction

function! Preserve(command)
  " preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  execute a:command
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

function! StripTrailingWhitespace()
  call Preserve("%s/\\s\\+$//e")
endfunction
"}}}

" base configuration ****************************************************************
set timeoutlen=300                                  "mapping timeout
set ttimeoutlen=50                                  "keycode timeout

set mouse=a                                         "enable mouse
set mousehide                                       "hide when characters are typed
set history=1000                                    "number of command lines to remember
set ttyfast                                         "assume fast terminal connection
set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
set encoding=utf-8                                  "set encoding for text
set clipboard=unnamed                               "sync with OS clipboard
set hidden                                          "allow buffer switching without saving
set autoread                                        "auto reload if file saved externally
set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal numbers
set showcmd
set tags=tags;/
set showfulltag
set modeline
set modelines=5
set noshelltemp                                     "use pipes

" whitespace
set backspace=indent,eol,start                      "allow backspacing everything in insert mode
set autoindent                                      "automatically indent to match adjacent lines
set expandtab                                       "spaces instead of tabs
set smarttab                                        "use shiftwidth to enter tabs
let &tabstop=s:settings.default_indent              "number of spaces per tab for display
let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
"set list                                            "highlight whitespace
set nolist
set listchars=trail:.,tab:>-,eol:$,tab:>.,trail:.,extends:#,nbsp:.
set shiftround
set nowrap
set linebreak
let &showbreak='↪ '

set scrolloff=1                                     "always show content after scroll
set scrolljump=5                                    "minimum number of lines to scroll
set display+=lastline
set wildmenu                                        "show list for autocomplete
set wildmode=list:full
set wildignorecase
set wildignore+=\*/node_modules/\*,\*/elm-stuff/\*,*.so,*.swp,*.zip

set splitbelow
set splitright

set fo-=r                                           "do not insert a comment leader after an enter, (no work, fix!!)

" disable sounds
set noerrorbells
set novisualbell
set t_vb=

" searching
set hlsearch                                        "highlight searches
set incsearch                                       "incremental searching
set ignorecase                                      "ignore case for searching
set smartcase                                       "do case-sensitive if there's a capital letter
if executable('ack')
  set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
  set grepformat=%f:%l:%c:%m
endif
if executable('ag')
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
endif

" indenting
set ai " Automatically set the indent of a new line (local to buffer)
set si " smartindent	(local to buffer)

" scrollbars
set sidescrolloff=2
set numberwidth=4

" vim file/folder management
" persistent undo
if exists('+undofile')
  set undofile
  let &undodir = s:get_cache_dir('undo')
endif

" backups
set backup
let &backupdir = s:get_cache_dir('backup')

" swap files
let &directory = s:get_cache_dir('swap')
set noswapfile

call EnsureExists(s:cache_dir)
call EnsureExists(&undodir)
call EnsureExists(&backupdir)
call EnsureExists(&directory)

let mapleader      = ' '
let maplocalleader = ' '

" ui configuration
set showmatch                                       "automatically highlight matching braces/brackets/etc.
set matchtime=2                                     "tens of a second to show matching parentheses
set number
set lazyredraw
set ruler
set laststatus=2
set noshowmode
set foldenable                                      "enable folds by default
set foldmethod=syntax                               "fold via syntax of files
set foldlevelstart=99                               "open all folds by default
let g:xml_syntax_folding=1                          "enable xml folding

set matchpairs+=<:>
set virtualedit=all

set cursorline
autocmd WinLeave * setlocal nocursorline
autocmd WinEnter * setlocal cursorline
if s:settings.enable_cursorcolumn
  set cursorcolumn
  autocmd WinLeave * setlocal nocursorcolumn
  autocmd WinEnter * setlocal cursorcolumn
endif

if $COLORTERM == 'gnome-terminal'
  set t_Co=256 "why you no tell me correct colors?!?!
endif
if $TERM_PROGRAM == 'iTerm.app'
  " different cursors for insert vs normal mode
  if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
  else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  endif
endif

" plugins+mappings {{{
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

if filereadable(expand("~/.vimrc.mappings"))
  source ~/.vimrc.mappings
endif
" }}}

" autocmd
autocmd FileType js,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> <leader>S vi{:sort<CR>
autocmd FileType python setlocal foldmethod=indent
autocmd FileType markdown setlocal nolist
autocmd FileType vim setlocal fdm=indent keywordprg=:help

filetype plugin indent on
syntax enable
set background=dark

exec 'colorscheme '.s:settings.colorscheme
