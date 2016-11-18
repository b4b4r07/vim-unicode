" Author: b4b4r07
" License: MIT

scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_unicode
endif
if exists('g:loaded_unicode')
  finish
endif
let g:loaded_unicode = 1
let s:save_cpo = &cpo
set cpo&vim

command! GetUtf8 echo unicode#get_utf8()
command! GetCodePoint echo unicode#get_code_point(unicode#get_utf8())

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
