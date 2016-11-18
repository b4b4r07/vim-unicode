" Author: b4b4r07
" License: MIT
" Original: http://d.hatena.ne.jp/krogue/20080616/1213590577

scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

" カーソル位置の文字を、UTF-8に変換した際の文字コードを返す
" 例) あ => E38182
function! unicode#get_utf8()
  let c = matchstr(getline('.'), '.', col('.') - 1)
  let c = iconv(c, &enc, 'utf-8')
  let s = ''
  for i in range(strlen(c))
    let s .= printf('%02X', char2nr(c[i]))
  endfor
  return s
endfunction

" UTF-8からコードポイントを返す
" ( BMP(U+0000..U+FFFF)のみに対応 )
" 例) E38182 => U+3040
function! unicode#get_code_point(utf8)
  let code = ''
  if a:utf8 =~ '^\x\{2}$'
    let code = '00' . a:utf8
  elseif a:utf8 =~ '^\x\{4}$'
    " 0x1F3Fを0x07FFに再配置する
    " 1バイト目を0x1C(00011100)でマスクし、2ビット右シフト(0x1C=>0x07)
    let h = printf('%d', '0x' . a:utf8[0:1]) * 8 % 256 / 8) / 4
    " 1バイト目を0x03(00000011)でマスクし、6ビット左シフト(0x03=>0xE0)
    let t = printf('%d', '0x' . a:utf8[0:1]) * 64 % 256
    " 2バイト目を0x3F(00111111)でマスクし、0xE0とOR結合
    let t += (printf('%d', '0x' . a:utf8[2:3]) * 4 % 256 / 4)
    let code = printf('%02X', h) . printf('%02X', t)
  elseif a:utf8 =~ '^\x\{6}$'
    " 0x0F3F3Fを0xFFFFに再配置する
    " 1バイト目を0x0F(00001111)でマスクし、4ビット左シフト(0x0F=>0xF0)
    let h = printf('%d', '0x' . a:utf8[0:1]) * 16 % 256
    " 2バイト目を0x3C(00111100)でマスクし、2ビット右シフト(0x3C=>0x0F)
    let h += (printf('%d', '0x' . a:utf8[2:3]) * 4 % 256 / 16)
    " 2バイト目を0x03(00000011)でマスクし、6ビット左シフト(0x03=>0xE0)
    let t = printf('%d', '0x' . a:utf8[2:3]) * 64 % 256
    " 3バイト目を0x3F(00111111)でマスクし、0xE0とOR結合
    let t += (printf('%d', '0x' . a:utf8[4:5]) * 4 % 256 / 4)
    let code = printf('%02X', h) . printf('%02X', t)
  else
    " TODO: error msg
  endif
  let code = 'U+' . code
  return code
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
