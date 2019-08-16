function! myspacevim#before() abort
  set updatetime=200
  set clipboard=unnamedplus
  let g:dein#install_max_processes=1
  let g:deoplete#enable_at_startup = 1
  let g:vimfiler_tree_leaf_icon = ' '
	let g:vimfiler_tree_opened_icon = '▾'
	let g:vimfiler_tree_closed_icon = '▸'
	let g:vimfiler_file_icon = '-'
	let g:vimfiler_marked_file_icon = '*'
endfunction

function! myspacevim#after() abort
  let g:indentLine_setConceal = 0
  autocmd FileType php EmmetInstall
  let g:neoformat_enabled_php = ['phpcbf']
endfunction
