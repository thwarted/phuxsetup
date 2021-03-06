" disable visible matching parens, I lose the cursor
:let loaded_matchparen = 1
set ts=4
set ruler
set expandtab
set listchars=tab:➔\ ,eol:␤
set ai
" hard to read on some terminals
set nohlsearch

" hilight the current line
set cursorline
"hi CursorLine term=none cterm=none ctermbg=4

au BufRead,BufNewFile *.js.php             setfiletype javascript
au BufRead,BufNewFile *.smarty             setfiletype smarty
" only first line has comment marker
au FileType * setl fo-=r

" consider trailing whitespace to be an error in the syntax highlight
autocmd FileType python syntax match ErrorMsg '\s\+$'
autocmd FileType puppet syntax match ErrorMsg '\s\+$'
autocmd FileType ruby syntax match ErrorMsg '\s\+$'

" fix odd coloring on quickfix entries
hi Search cterm=NONE ctermfg=grey ctermbg=blue
