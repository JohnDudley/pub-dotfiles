" vim:set sw=2 sts=2 fdm=marker:
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-speeddating'
Plugin 'tpope/vim-jdaddy'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-scriptease'
Plugin 'tpope/vim-unimpaired'
Plugin 'mhinz/vim-signify'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-syntastic/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'spolu/dwm.vim'
Plugin 'haya14busa/is.vim'
Plugin 'haya14busa/vim-asterisk'
Plugin 'raimon49/requirements.txt.vim'
Plugin 'majutsushi/tagbar'
Plugin 'tomtom/tcomment_vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'Shougo/unite.vim'
Plugin 'vim-scripts/vcscommand.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'gko/vim-coloresque'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'junegunn/vim-easy-align'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'sheerun/vim-polyglot'
Plugin 'mhinz/vim-startify'
Plugin 'ludwig/split-manpage.vim'
Plugin 'rizzatti/dash.vim'
Plugin 'dense-analysis/ale'
Plugin 'easymotion/vim-easymotion'
Plugin 'nathanaelkane/vim-indent-guides'

" perform :PluginInstall to install plugins
"
" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
" To ignore plugin indent changes, instead use:
"filetype plugin on

set runtimepath+=~/.vim_local
" useful commands                                                    {{{1
"
" (show colours)  :so $VIMRUNTIME/syntax/hitest.vim
"
"
":Helptags

" leaders                                                            {{{1
let mapleader=","
let maplocalleader="\\"

" settings                                                           {{{1
:set tags=./.tags;,~/.vimtags
:let g:easytags_dynamic_files=1
":let g:easytags_by_filetype=1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"let g:syntastic_c_errorformat='%m'
if !&diff
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 2
  let g:syntastic_auto_jump = 3
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_cobol_compiler = "cblValidate"
  let g:syntastic_cpp_check_header = 1
  let g:syntastic_cpp_remove_include_errors = 1
endif

if &diff
    set diffopt+=iwhite
endif

" functions                                                          {{{1
function! Setline(text,...) abort
  let l = ( a:0>0 ? a:1 : line('.'))
  return setline(a:text,l)
endfunction

let $in_hex=0
function! HexMode()
  set binary
  set noeol
  if $in_hex>0
    :%!xxd -r
    let $in_hex=0
  else
    :%!xxd
    let $in_hex=1
  endif
endfunction

let $toggleTagListStatus = 0
function! ToggleTagList()
  if $toggleTagListStatus > 0
    :TlistToggle
"    let &colorcolumn=join(range(72,255),",")
    let toggleTagListStatus = 0
  else
    :TlistToggle
"    let &colorcolumn=join(range(1,8),",").join(range(72,255),",")
    let toggleTagListStatus = 1
  endif
endfunction

function! ToggleSyntax()
  if exists("g:syntax_on")
    syntax off
  else
    syntax enable
  endif
endfunction

function! CompileCurrent()
  let $fn=expand("%:t")
  if !&readonly
    write
    :!qc $fn debug
  endif
endfunction

function! DebugCurrent()
  call CompileCurrent()
  let $fn=expand("%:t")
  :!qd $fn
endfunction

function! COBOLCommentToggle()
  let l:currline = getline('.')
  if match(l:currline, '\v^......\*') >= 0
    let l:newline = substitute(l:currline, '^\(......\).\(.*\)$', '\1 \2', '')
  else
    let l:newline = substitute(l:currline, '^\(......\).\(.*\)$', '\1*\2', '')
  endif
  call setline('.', l:newline)
endfunction

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

function! SetListCharsOn()
  if &encoding ==? 'utf-8'
"  if &termencoding == 'utf-8'
    set termencoding=utf-8
    set listchars=tab:»·,trail:·,nbsp:·,eol:¶
  else
    set termencoding=latin1
    set listchars=tab:>.,trail:.,nbsp:.,eol:$
"    set listchars=tab:»·,trail:·,nbsp:·
  endif
endfunction

function! SetListCharsOff()
  set listchars=
endfunction

" Verify len(varArgs) <= maxNumArgs, then return a modifiable copy of varArgs.
function! VarArgs(maxNumArgs, varArgs)
    let args = copy(a:varArgs)
    if len(args) > a:maxNumArgs
        throw "Too many arguments supplied (>" . a:maxNumArgs . ")"
    endif
    return args
endfunction

" Verify len(varArgs) is 0 or 1; return sole arg or defaultValue if none given.
function! OptArg(varArgs, defaultValue)
    return ListPop(VarArgs(1, a:varArgs), a:defaultValue)
endfunction

" Pop leftmost element from list; if list is empty, return defaultValue instead.
function! ListPop(list, defaultValue)
    let value = a:defaultValue
    if len(a:list) > 0
        let value = a:list[0]
        unlet a:list[0]
    endif
    return value
endfunction

function! ExecInPlace(cmd)
    let pos = winsaveview()
    execute a:cmd
    call winrestview(pos)
endfunction

" SubInPlace(pattern, replacement, flags?, line1?, line2?)
" Performs "in-place" substitution of pattern to replacement.
" Defaults: flags='g', line1='1', line2='$'.
function! SubInPlace(pattern, replacement, ...)
    let args = VarArgs(3, a:000)
    let flags = ListPop(args, 'g')
    let line1 = ListPop(args, '1')
    let line2 = ListPop(args, '$')
    let cmd = line1 . ',' . line2 . 's/'
    let cmd .= a:pattern . '/' . a:replacement . '/' . flags
    call ExecInPlace(cmd)
    call histdel("/", -1)
endfunction

" Convert lowerMixedCase to hyphen-separated-lowercase, e.g.:
"   "multiWordVariable" ==> "multi-word-variable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Hyphens()/g
function! Hyphens(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C([A-Z]+)([A-Z][a-z])', '\1-\2', "g")
    let word = substitute(word, '\v\C([a-z\d])([A-Z])', '\1-\2', "g")
    let word = tolower(word)
    return word
endfunction

" Convert lowerMixedCase to underscore_separated_lowercase, e.g.:
"   "multiWordVariable" ==> "multi_word_variable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Underscore()/g
function! Underscore(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C([A-Z]+)([A-Z][a-z])', '\1_\2', "g")
    let word = substitute(word, '\v\C([a-z\d])([A-Z])', '\1_\2', "g")
    let word = tolower(word)
    return word
endfunction


" Convert hyphen-separated-lowercase to lowerMixedCase, e.g.:
"   "multi-word-variable" ==> "multiWordVariable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Umc()/g
function! Hlmc(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C(^|_|-)(.)', '\u\2', "g")
    return tolower(word[:0]) . word[1:]
endfunction

" Convert underscore_separated_lowercase to UpperMixedCase, e.g.:
"   "multi_word_variable" ==> "MultiWordVariable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Umc()/g
function! Umc(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C(^|_)(.)', '\u\2', "g")
    return word
endfunction


" Convert underscore_separated_lowercase to lowerMixedCase, e.g.:
"   "multi_word_variable" ==> "multiWordVariable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Lmc()/g
function! Lmc(...)
    let word = Umc(OptArg(a:000, submatch(0)))
    return tolower(word[:0]) . word[1:]
endfunction

function! SubArgsOrCword(line1, line2, args, replacement)
    if len(a:args) == 0
        let regex = '\v\C<' . expand('<cword>') . '>'
    else
        let regex = '\v\C<' . join(a:args, '>|<') . '>'
    endif
    call SubInPlace(regex, a:replacement, 'g', a:line1, a:line2)
endfunction

command! -bar -range=% -nargs=* ToHyphens
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Hyphens()')

command! -bar -range=% -nargs=* ToUnderscore
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Underscore()')

command! -bar -range=% -nargs=* ToHlmc
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Hlmc()')

command! -bar -range=% -nargs=* ToUmc
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Umc()')

command! -bar -range=% -nargs=* ToLmc
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Lmc()')

command! -bar -range=% LmcToUnderscore
        \ call SubInPlace(SearchLmcPattern(), '\=Underscore()', 'g',
        \ <line1>, <line2>)

" Mandatory Setup                                                    {{{1
"enable syntax highlighting and relevant options
syntax on
filetype plugin indent on

" Basic options                                                      {{{1
set nocompatible

" Set encodings
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,latin1
set bomb
set binary
set ttyfast

" file formats
set fileformats=unix,dos,mac

" turn off file backups
set nobackup
set noswapfile

" Indent, tabs, etc
set backspace=indent,eol,start
set tabstop=4
set softtabstop=0
set shiftwidth=4
set autoindent
set copyindent
set smartindent

" visual elements
set ruler
set showcmd
set showmode
set number
set hidden
set wildmenu
set wildmode=list:longest
set wildignore+=*.swp
set infercase
set laststatus=2
set updatecount=20
set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y\ \ (%c,%l/%LL\ %P)
set scrolloff=5

" Search Options
set ignorecase
set smartcase
set hlsearch
set incsearch
set gdefault
set showmatch

set history=1000
set undolevels=1000
set nowrap

set matchpairs=(:),{:},[:],<:>
"set expandtab

" Allow project specific vimrc
set exrc
set secure


if &term =~ "xterm"
  " 256 colors
  let &t_Co = 256
  " restore screen after quitting
  "  let &t_ti = "\<Esc>7\<Esc>[r\<Esc>[?47h"
  "  let &t_te = "\<Esc>[?47l\<Esc>8"
  let &t_SI .= "\<Esc>[?2004h"
  let &t_EI .= "\<Esc>[?2004l"
  if has("terminfo")
    let &t_Sf = "\<Esc>[3%p1%dm"
    let &t_Sb = "\<Esc>[4%p1%dm"
  else
    let &t_Sf = "\<Esc>[3%dm"
    let &t_Sb = "\<Esc>[4%dm"
  endif
endif

"let g:netrw_liststyle=3
"let g:netrw_keepdir=0
"let VCSCommandVCSExec="/usr/bin/svn18"
let VCSCommandSVNExec="/usr/bin/svn18"

set <S-F5>=^[[28~
set <S-F6>=^[[29~

" set filetypes etc                                                  {{{1
"au BufNewFile,BufRead *.csv,*.dat set filetype=csv
au BufNewFile,BufRead *.CBL set filetype=cobol
au BufNewFile,BufRead *.cbl.tpl set filetype=cobol
au BufNewFile,BufRead $SRC/lib/* set filetype=cobol
au BufNewFile,BufRead $SRC/jdlib/* set filetype=cobol
au BufNewFile,BufRead $SRC/orlib/* set filetype=cobol
au BufNewFile,BufRead $SRC/gui/* set filetype=cobol
au BufNewFile,BufRead $SRC/filedef/* set filetype=cobol
au BufNewFile,BufRead $SRC/mqlib/* set filetype=cobol
au BufNewFile,BufRead $PRJDIR/build/list/* set filetype=cobollist
au BufNewFile,BufRead *.make set filetype=make
au BufNewFile,BufRead *.wsdl set filetype=xml
au BufNewFile,BufRead *.xsd set filetype=xml
au BufNewFile,BufRead makefile.tpl set filetype=make
au BufNewFile,BufRead *.ServiceDefinition set filetype=config
au BufNewFile,BufReadPost *.md set filetype=markdown

"let g:cobol_folds = 1
aug cobolFileType
  au!
  au BufNewFile *.cbl 0r $HOME/.vim/templates/cobol.tpl
  au FileType cobol set sw=2 sts=2 et sta tw=72 expandtab formatoptions-=c formatoptions-=r formatoptions-=o 
  au FileType cobol let g:easytags_opts = ['--language-force=cobol']
  au FileType cobol let &colorcolumn="7,73"
"  au FileType cobol let &colorcolumn=join(range(73,255),",")
"  au FileType cobol let &colorcolumn=join(range(1,8),",").join(range(72,255),",")
  au FileType cobol match ErrorMsg '\%>72v.\+'
  au FileType cobol set path=$SRC/**
  au FileType cobol set path+=$SRC/jdlib/**
  au FileType cobol set path+=$SRC/lib/**
  au FileType cobol set path+=$SRC/orlib/**
  au FileType cobol set path+=$SRC/gui/**
  au FileType cobol set path+=$SRC/filedef/**
  au FileType cobol set path+=$SRC/mqlib/**
  au FileType cobol set fileencodings=latin1
  au FileType cobol set encoding=cp437
  au FileType cobol set fileencoding=cp437
  au FileType cobol setlocal fileencodings=cp437,utf-8
  au FileType cobol setlocal fileencodings=cp437,utf-8
  au FileType cobol syntax sync minlines=250
  au FileType cobol let g:airline_powerline_fonts = 0
  au FileType cobol let g:airline_left_sep='>'
  au FileType cobol let g:airline_right_sep='<'
  au FileType cobol let g:airline_left_alt_sep = '>'
  au FileType cobol let g:airline_right_alt_sep = '<'
  au FileType cobol setlocal commentstring="^     * %s"
" COBOL Specific
" unindent
  au FileType cobol nnoremap <buffer> <localleader>u <C-\><C-N>0lllllllxx<C-\><C-N>j
" indent
  au FileType cobol nnoremap <buffer> <localleader>i <C-\><C-N>0llllllli<space><space><C-\><C-N>j
" uncomment
  au FileType cobol nnoremap <buffer> <localleader>x <C-\><C-N>0llllllR<space><C-\><C-N>j
" comment
  au FileType cobol nnoremap <buffer> <localleader>C :call COBOLCommentToggle()<cr>
  au FileType cobol nnoremap <buffer> <localleader>c <C-\><C-N>0llllllR*<C-\><C-N>j
" Section comment
  au FileType cobol nnoremap <buffer> <localleader>s <C-\><C-N>O<C-\><C-N>0i<space><space><space><space><space><space>*-----------------------------------------------------------------<CR>*<CR>*-----------------------------------------------------------------<CR><space>newSection section.<CR><space><space><space><space>.<CR><C-\><C-N>
aug END

aug cppFileType
  au!
  autocmd BufRead, BufNewFile *.h,*.c,*.cpp set filetype=cpp
  au FileType cpp set sw=4 sts=4 et sta noexpandtab
  au FileType cpp set path+=$PRJBASE/runtime/ActiveMQ/activemq-c-1.1/**
  au FileType cpp set path+=$PRJBASE/runtime/ActiveMQ/activemq-cpp-library-3.9.3/src/main/**
  au FileType cpp set path+=$PRJBASE/runtime/ActiveMQ/apr-1.5.2/**
  au FileType cpp set path+=$PRJBASE/runtime/ActiveMQ/ezs-1.4.2/**
aug END

autocmd FileType php set sw=4 sts=4 et sta noexpandtab
autocmd FileType perl set sw=4 sts=4 et sta noexpandtab
autocmd FileType expect set sw=4 sts=4 et sta expandtab
autocmd FileType c set sw=4 sts=4 et sta expandtab
autocmd FileType python set sw=4 sts=4 et sta expandtab formatoptions-=c formatoptions-=r formatoptions-=o
autocmd FileType config set sw=4 sts=4 et sta expandtab

" Airline                                                            {{{1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_inactive_collapse=1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1
"let g:airline#extensions#branch#use_vcscommand = 1
let g:airline_section_warning = ''
if &encoding ==# 'utf-8'
  let g:airline_powerline_fonts = 1
endif

set foldcolumn=4

" Promptline                                                         {{{1
"let g:promptline_preset = {
"        \'a' : [ promptline#slices#host() ],
"        \'b' : [ '$(pwd)' ],
"        \'c' : [ promptline#slices#vcs_branch({ 'svn' : 1 })],
"        \'warn' : [ '$(/usr/bin/svnversion 2>/dev/null)' ]}

" TagBar                                                             {{{1
let g:tagbar_sort=0
let g:tagbar_show_linenumbers=0

" Easy Align                                                         {{{1
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" remap some keys                                                    {{{1

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Open file under cursor in current window
nnoremap <silent> <leader><space> gf
" Open file under cursor in new window
nnoremap <silent> <leader><CR> <C-W>f

" clear search
nnoremap <silent> <leader>. :noh<CR>

"edit/source vimrc
nnoremap <silent> <leader>ve :e $MYVIMRC<CR>
nnoremap <silent> <leader>vs :so $MYVIMRC<CR>

" List chars on/off
nnoremap <leader>lO :call SetListCharsOn()<CR>
nnoremap <leader>lo :call SetListCharsOff()<CR>

nnoremap <C-N><C-N> :set invnumber<CR>
nnoremap <2-LeftMouse> *
nnoremap <C-2-LeftMouse> gf
nnoremap <C-S-2-LeftMouse> <C-W>f
nnoremap <silent> <F1> :NERDTreeToggle<CR>
nnoremap <silent> <F2> :BufExplorer<CR>
nnoremap <localleader>b :call CompileCurrent()<CR>
nnoremap <localleader>d :call DebugCurrent()<CR>
nnoremap <S-F2> :call CompileCurrent()<CR>
nnoremap <F3> :set invpaste paste?<CR>
set pastetoggle=<F3>
set showmode
nnoremap <silent> <F5> :bp<CR>
nnoremap <silent> <F6> :bn<CR>
nnoremap <silent> <F7> :lprev<CR>
nnoremap <silent> <F8> :lnext<CR>
nnoremap <silent> <F9> :call ToggleSyntax()<CR>
nnoremap <F12> :e ++enc=utf-8<CR>
nnoremap <S-F1> <C-\><C-N>:TOhtml<C-\><C-N>

" Refactor/rename identifer under cursor.
nnoremap <localleader>h :ToHyphens<CR>
nnoremap <localleader>H :ToHlmc<CR>
nnoremap <localleader>j :ToUnderscore<CR>
nnoremap <localleader>J :ToLmc<CR>

" Use space to jump down a page
"nnoremap <Space> <PageDown>
"vnoremap <Space> <PageDown>

" make * respect smartcase and also ser @/ to enable 'n' and 'N'
nmap * :let @/ = '\<'.expand(tolower('<cword>')).'\>' ==? @/ ? @/ : '\<'.expand(tolower('<cword>')).'\>'<CR>n

"
" Buffers - explore/next/previous: Alt-F12, F12, Shift-F12.
"nnoremap <silent> <M-F12> :BufExplorer<CR>

" fold on search results
"nnoremap \z :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=3<CR>
"
"
" Try and get auto paste toggle to work
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" EasyMotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
nmap s <Plug>(easymotion-overwin-f2)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" vim-asterisk
"map *   <Plug>(asterisk-*)<Plug>(is-nohl-1)
"map #   <Plug>(asterisk-#)<Plug>(is-nohl-1)
"map g*  <Plug>(asterisk-g*)<Plug>(is-nohl-1)
"map g#  <Plug>(asterisk-g#)<Plug>(is-nohl-1)
"map *   <Plug>(asterisk-*)
"map #   <Plug>(asterisk-#)
"map g*  <Plug>(asterisk-g*)
"map g#  <Plug>(asterisk-g#)
"map z*  <Plug>(asterisk-z*)
"map gz* <Plug>(asterisk-gz*)
"map z#  <Plug>(asterisk-z#)
"map gz# <Plug>(asterisk-gz#)

" NERDTree configuration
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
"nnoremap <silent> <F2> :NERDTreeFind<CR>

" grep.vim
nnoremap <silent> <leader>f :Rgrep<CR>
let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Tabs
"nnoremap <Tab> gt
"nnoremap <S-Tab> gT
"nnoremap <silent> <S-t> :tabnew<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" snippets
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsExpandTrigger="<c-j>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"

" syntastic
"let g:syntastic_always_populate_loc_list=1
let g:syntastic_error_symbol='x'
let g:syntastic_warning_symbol='w'
let g:syntastic_style_error_symbol = 'x'
let g:syntastic_style_warning_symbol = 'w'
"let g:syntastic_auto_loc_list=1
"let g:syntastic_aggregate_errors = 1

" Tagbar
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 1

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

noremap YY "+y<CR>
noremap <leader>p "+gP<CR>
noremap XX "+x<CR>

"" Buffer nav
noremap <leader>z :bp<CR>
noremap <leader>q :bp<CR>
noremap <leader>x :bn<CR>
noremap <leader>w :bn<CR>

"" Close buffer
noremap <leader>c :bd<CR>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"
" Cursor line
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

" mouse reporting
if has('mouse_sgr')
    set ttymouse=sgr
endif

" set colours
set background=dark
if &term ==? "xterm" || &term ==? "shogun" || &term ==? "xterm-256color"
  set mouse=a
  colorscheme jdcolour
  " set nonprintable chars
  set list
"  if &encoding ==? 'utf-8'
"    set termencoding=utf-8
"    set listchars=tab:Â»Â·,trail:Â·,nbsp:Â·,eol:Â¶
"  else
"    set termencoding=latin1
"    set listchars=tab:»·,trail:·,nbsp:·
"  endif
  call SetListCharsOn()
else
  colorscheme jdcolour
  set listchars=tab:»·,trail:·,nbsp:·
"  set listchars=tab:Â¯Ãº,trail:Ãº,nbsp:Ãº
endif

" alias some common operations                                       {{{1
let @c=']cdp'


try
	source ~/.vimrc_local
catch
" ignore missing file
endtry
