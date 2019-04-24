let g:indentLine_setConceal = 0
augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END
