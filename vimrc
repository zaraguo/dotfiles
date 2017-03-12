" vim: foldmethod=marker ts=2 sts=2 sw=2 fdl=0

" detect OS
let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_macvim = has('gui_macvim')
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

function! EnsureExists(path)
  if !isdirectory(expand(a:path))
    call mkdir(expand(a:path))
  endif
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

map <S-Enter> O<ESC>                                "awesome, inserts new line without going into insert mode
map <Enter> o<ESC>
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

"if has('conceal')
"  set conceallevel=1
"  set listchars+=conceal:Δ
"endif

if has('gui_running')
  " open maximized
  set lines=57 columns=175

  set anti                                          " Antialias font
  set gtl=%t gtt=%F                                 " Tab headings

  if s:is_windows
    autocmd GUIEnter * simalt ~x
  endif

  set guioptions+=t                                 "tear off menu items
  set guioptions-=T                                 "toolbar icons
  set guioptions-=r                                 "remove right scrollbar
  set guioptions-=L                                 "remove left scrollbar

  if s:is_macvim
    set gfn=Monaco\ for\ Powerline:h13
    set transparency=0
  endif

  if s:is_windows
    set gfn=Ubuntu_Mono:h10
  endif

  if has('gui_gtk')
    set gfn=Ubuntu\ Mono\ 11
  endif
else
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
endif

" plugins
" ***************************************************************************************
call plug#begin('~/.vim/plugged')

" ----------------------------------------------------------------------------
" <Enter> | vim-easy-align {{{
" ----------------------------------------------------------------------------
Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign'] }

let g:easy_align_delimiters = {
\ '>': { 'pattern': '>>\|=>\|>' },
\ '\': { 'pattern': '\\' },
\ '/': { 'pattern': '//\+\|/\*\|\*/', 'delimiter_align': 'l', 'ignore_groups': ['!Comment'] },
\ ']': {
\     'pattern':       '\]\zs',
\     'left_margin':   0,
\     'right_margin':  1,
\     'stick_to_left': 0
\   },
\ ')': {
\     'pattern':       ')\zs',
\     'left_margin':   0,
\     'right_margin':  1,
\     'stick_to_left': 0
\   },
\ 'f': {
\     'pattern': ' \(\S\+(\)\@=',
\     'left_margin': 0,
\     'right_margin': 0
\   },
\ 'd': {
\     'pattern': ' \ze\S\+\s*[;=]',
\     'left_margin': 0,
\     'right_margin': 0
\   }
\ }

" Start interactive EasyAlign in visual mode
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign with a Vim movement
nmap ga <Plug>(EasyAlign)
nmap gaa ga_

" xmap <Leader><Enter>   <Plug>(LiveEasyAlign)
" nmap <Leader><Leader>a <Plug>(LiveEasyAlign)

" inoremap <silent> => =><Esc>mzvip:EasyAlign/=>/<CR>`z$a<Space>
" }}}

" ----------------------------------------------------------------------------
" goyo.vim + limelight.vim {{{
" ----------------------------------------------------------------------------
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

let g:limelight_paragraph_span = 1
let g:limelight_priority = -1

function! s:goyo_enter()
  if has('gui_running')
    set fullscreen
    " set background=light
    set linespace=7
  elseif exists('$TMUX')
    silent !tmux set status off
  endif
  " hi NonText ctermfg=101
  Limelight
endfunction

function! s:goyo_leave()
  if has('gui_running')
    set nofullscreen
    set background=dark
    set linespace=0
  elseif exists('$TMUX')
    silent !tmux set status on
  endif
  Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nnoremap <Leader>G :Goyo<CR>
" }}}

" ============================================================================
" FZF {{{
" ============================================================================
Plug 'junegunn/fzf',        { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

if has('nvim')
  let $FZF_DEFAULT_OPTS .= ' --inline-info'
  " let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

" File preview using CodeRay (http://coderay.rubychan.de/)
let g:fzf_files_options =
  \ '--preview "coderay {} 2> /dev/null | head -'.&lines.'"'

" nnoremap <silent> <Leader><Leader> :Files<CR>
nnoremap <silent> <expr> <Leader><Enter> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <Leader><Leader> :Buffers<CR>
nnoremap <silent> <Leader>C        :Colors<CR>
nnoremap <silent> <Leader>ag       :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
nnoremap <silent> <Leader>`        :Marks<CR>
" nnoremap <silent> q: :History:<CR>
" nnoremap <silent> q/ :History/<CR>

nnoremap <silent> <Leader>n        :bn<CR>
nnoremap <silent> <Leader>p        :b#<CR>

inoremap <expr> <c-x><c-t> fzf#complete('tmuxwords.rb --all-but-current --scroll 500 --min 5')
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

command! Plugs call fzf#run({
  \ 'source':  map(sort(keys(g:plugs)), 'g:plug_home."/".v:val'),
  \ 'options': '--delimiter / --nth -1',
  \ 'down':    '~40%',
  \ 'sink':    'Explore'})
" }}}

" ----------------------------------------------------------------------------
" Navigation/Searching {{{
" ----------------------------------------------------------------------------
Plug 'rking/ag.vim', { 'on': 'Ag' } "{{{
  let g:ag_working_path_mode="r"
"}}}

Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'} "{{{
  let NERDTreeShowHidden=1
  let NERDTreeQuitOnOpen=0
  let NERDTreeShowLineNumbers=0
  let NERDTreeChDirMode=0
  let NERDTreeShowBookmarks=0
  let NERDTreeHijackNetrw=1
  let NERDTreeMapJumpNextSibling="]"
  let NERDTreeMapJumpPrevSibling="["
  let NERDTreeIgnore=['\.git', '\.hg', '\.svn$', '\~$', '\.pyc$', '\.beam$', '\.gz$', 'cscope\.*', '\.[ao]$', '\.so$']
  let NERDTreeBookmarksFile=s:get_cache_dir('NERDTreeBookmarks')
  nnoremap <leader>t :NERDTreeToggle<CR>
"}}}

Plug 'easymotion/vim-easymotion' "{{{
  let g:EasyMotion_do_mapping = 0 " Disable default mappings
  map <leader> <Plug>(easymotion-prefix)
  " Bi-directional find motion
  " Jump to anywhere you want with minimal keystrokes, with just one key binding.
  " `s{char}{char}{label}`
  " Need one more keystroke, but on average, it may be more comfortable.
  nmap s <Plug>(easymotion-s2)
  nmap t <Plug>(easymotion-t2)
  "" Turn on case insensitive feature
  let g:EasyMotion_smartcase = 1
  " JK motions: Line motions
  map <leader>j <Plug>(easymotion-j)
  map <leader>k <Plug>(easymotion-k)
"}}}"

" clear search highlight
map <leader>sc :nohl<CR>

"}}}

" ----------------------------------------------------------------------------
" UI {{{
" ----------------------------------------------------------------------------
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes' "{{{
  let g:airline_theme = "bubblegum"
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tmuxline#enabled = 0
  let g:airline#extensions#whitespace#enabled = 1
  let g:airline#extensions#tagbar#enabled = 1
  function! AirlineInit()
    let g:airline_section_b = airline#section#create(['branch'])
    let g:airline_section_c = '%<%t%m'
    let g:airline_section_warning = airline#section#create(['syntastic'])
  endfunction
  autocmd VimEnter * if exists(':AirlineToggle') | call AirlineInit()
"}}}

" colors
Plug 'junegunn/seoul256.vim'
Plug 'tomasr/molokai'
Plug 'chriskempson/vim-tomorrow-theme'

if exists('$TMUX')
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'benmills/vimux' "{{{
    " Run the current file with rspec
    "map <leader>vb :call VimuxRunCommand("clear; rspec " . bufname("%"))<CR>
    " Prompt for a command to run
    map <leader>vp :VimuxPromptCommand<CR>
    " Run last command executed by VimuxRunCommand
    map <leader>vl :VimuxRunLastCommand<CR>
    " Inspect runner pane
    map <leader>vi :VimuxInspectRunner<CR>
    " Close vim tmux runner opened by VimuxRunCommand
    map <leader>vq :VimuxCloseRunner<CR>
    " Interrupt any command running in the runner pane
    map <leader>vx :VimuxInterruptRunner<CR>
    " Zoom the runner pane (use <bind-key> z to restore runner pane)
    map <leader>vz :call VimuxZoomRunner()<CR>
  "}}}"
  Plug 'edkolev/tmuxline.vim'
    let g:tmuxline_preset = 'powerline'
    let g:tmuxline_theme = 'powerline'
endif

Plug 'ShowTrailingWhitespace'

Plug 'mhinz/vim-startify' "{{{
  let g:startify_session_dir = s:get_cache_dir('sessions')
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1
  nnoremap <F1> :Startify<cr>
"}}}
Plug 'ryanoasis/vim-devicons' "{{{
  let g:webdevicons_enable_nerdtree = 1
  let g:webdevicons_enable_ctrlp = 1
  let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
  let g:DevIconsEnableFoldersOpenClose = 1
  let g:WebDevIconsOS = 'Darwin'
"}}}

"}}}

" ----------------------------------------------------------------------------
" SCM {{{
" ----------------------------------------------------------------------------
Plug 'mhinz/vim-signify'
  let g:signify_disable_by_default=1
  let g:signify_update_on_bufenter=0

Plug 'tpope/vim-fugitive'
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>gl :Glog<CR>
  nnoremap <silent> <leader>gp :Git push<CR>
  nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>gr :Gremove<CR>
  autocmd BufReadPost fugitive://* set bufhidden=delete
"}}}

" ----------------------------------------------------------------------------
" Editing {{{
" ----------------------------------------------------------------------------
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'

Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'jiangmiao/auto-pairs' "{{{
  let g:AutoPairsFlyMode = 0
"}}}

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
  let g:undotree_SplitLocation='botright'
  let g:undotree_SetFocusWhenToggle=1
  let g:undotree_WindowLayout = 2
  nnoremap U :UndotreeToggle<CR>

Plug 'bufkill.vim'
  nnoremap <leader>d :BD<cr>
"}}}

" ----------------------------------------------------------------------------
" Completion {{{
" ----------------------------------------------------------------------------
Plug 'honza/vim-snippets'

Plug 'Valloric/YouCompleteMe'
  let g:ycm_complete_in_comments_and_strings=1
  let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
  let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
  let g:ycm_filetype_blacklist={'unite': 1}

Plug 'SirVer/ultisnips'
  let g:UltiSnipsExpandTrigger="<tab>"
  let g:UltiSnipsJumpForwardTrigger="<tab>"
  let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
  let g:UltiSnipsSnippetsDir='~/.vim/snippets'
"}}}

" ----------------------------------------------------------------------------
" Clojure {{{
" ----------------------------------------------------------------------------

Plug 'guns/vim-sexp',       { 'for': 'cojure' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-clojure-highlight'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'tpope/vim-sexp-mappings-for-regular-people', { 'for': 'clojure' }

augroup vimrc
  autocmd FileType lisp,clojure,scheme RainbowParentheses
  autocmd FileType lisp,clojure,scheme
        \ nnoremap <buffer> <leader>a[ vi[<c-v>$:EasyAlign\ g/^\S/<cr>gv=
  autocmd FileType lisp,clojure,scheme
        \ nnoremap <buffer> <leader>a{ vi{<c-v>$:EasyAlign\ g/^\S/<cr>gv=
  autocmd FileType lisp,clojure,scheme
        \ nnoremap <buffer> <leader>a( vi(<c-v>$:EasyAlign\ g/^\S/<cr>gv=
  autocmd FileType lisp,clojure,scheme
        \ nnoremap <buffer> <leader>rq :silent update<bar>Require!<cr>
  autocmd FileType lisp,clojure,scheme
        \ nnoremap <buffer> <leader>rt :silent update<bar>RunTests<cr>
augroup END

let g:clojure_maxlines = 30

" let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

" }}}

" ----------------------------------------------------------------------------
" javascript {{{
" ----------------------------------------------------------------------------
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'maksimr/vim-jsbeautify', { 'for': 'javascript' }
  nnoremap <leader>fjs :call JsBeautify()<cr>
" Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
Plug 'elzr/vim-json', { 'for': 'json' }
" }}}

" ----------------------------------------------------------------------------
" markdown {{{
" ----------------------------------------------------------------------------
Plug 'tpope/vim-markdown',    { 'for': 'markdown' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown' }
" }}}

" ----------------------------------------------------------------------------
" Erlang/Elixir {{{
" ----------------------------------------------------------------------------
Plug 'jimenezrick/vimerl', { 'for': ['erlang', 'elixir'] }
  let g:erlang_highlight_bif = 1
  let erlang_show_errors = 0
Plug 'elixir-lang/vim-elixir', { 'for': 'elixir' }
if has('nvim')
  Plug 'thinca/vim-ref'
  Plug 'awetzel/elixir.nvim', {
        \ 'for': 'elixir',
        \ 'do': 'yes \| ./install.sh'
        \}
  let g:elixir_maxmenu = 30
  let g:elixir_docpreview = 0
  let g:elixir_showerror = 0
  let g:elixir_autobuild = 0
endif
" }}}

" ----------------------------------------------------------------------------
" Rust {{{
" ----------------------------------------------------------------------------
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
autocmd BufWrite *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&"

" }}}

call plug#end()

" mappings
" ********************************************************************************
" formatting shortcuts
nmap <leader>fef :call Preserve("normal gg=G")<CR>
nmap <leader>f$ :call StripTrailingWhitespace()<CR>
"vmap <leader>s :sort<cr>

nnoremap <leader>w :w<cr>

" toggle paste
map <F6> :set invpaste<CR>:set paste?<CR>

" smash escape
"inoremap jj <esc>
inoremap fd <esc>

inoremap <C-]> <C-o>l

" cscope
nmap <C-[>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-[>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-[>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" folds
nnoremap zr zr:echo &foldlevel<cr>
nnoremap zm zm:echo &foldlevel<cr>
nnoremap zR zR:echo &foldlevel<cr>
nnoremap zM zM:echo &foldlevel<cr>

" screen line scroll
nnoremap <silent> j gj
nnoremap <silent> k gk

" find current word in quickfix
nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
" find last search in quickfix
nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

" shortcuts for windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" hide annoying quit message
nnoremap <C-c> <C-c>:echo<cr>

" quick buffer open
nnoremap gb :ls<cr>:e #

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
