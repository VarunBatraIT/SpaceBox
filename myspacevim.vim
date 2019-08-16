function! myspacevim#before() abort
  set updatetime=200
  set clipboard=unnamedplus
  let g:dein#install_max_processes=1
  let g:deoplete#enable_at_startup = 1
endfunction

function! myspacevim#after() abort
  let g:indentLine_setConceal = 0
  autocmd FileType php EmmetInstall
  let g:neoformat_enabled_php = ['phpcbf']
endfunction
