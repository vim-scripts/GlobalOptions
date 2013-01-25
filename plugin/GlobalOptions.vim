" GlobalOptions.vim: Turn global options into buffer- or window-local ones.
"
" DEPENDENCIES:
"   - GlobalOptions/Command.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	02-Jan-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_GlobalOptions') || (v:version < 700)
    finish
endif
let g:loaded_GlobalOptions = 1

command! -nargs=* -complete=option SetBufferLocal call GlobalOptions#Command#BufferLocal(<q-args>)
command! -nargs=* -complete=option SetWindowLocal call GlobalOptions#Command#WindowLocal(<q-args>)

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
