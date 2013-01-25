" GlobalOptions.vim: Turn global options into buffer- or window-local ones.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	004	03-Jan-2013	Include "#<buffer>" pattern in filter;
"				otherwise, the predicate will be true in
"				non-BufferLocal buffers, too. (Though it
"				shouldn't matter, as s:save_globals isn't filled
"				there.)
"				FIX: Must include * event pattern to remove
"				the group's autocmds for the current buffer.
"	003	02-Jan-2013	Add GlobalOptions#GetBufferLocals() to allow
"				newly introduced :SetBufferLocal command access.
"	002	28-Dec-2012	Move existence of saved value check into
"				s:Push() to fix when dropping file with
"				buffer-local setting.
"	001	26-Dec-2012	file creation

let s:save_globals = {}
function! s:Push( option, value )
    if ! has_key(s:save_globals, a:option)
	execute 'let s:save_globals[a:option] = &g:' . a:option
    endif
    execute 'let &g:' . a:option '=' string(a:value)
"****D echomsg '**** Push' a:option . '=' . a:value 'over' s:save_globals[a:option]
endfunction
function! s:Pop( option )
    if has_key(s:save_globals, a:option)
"****D echomsg '**** Pop ' a:option . '=' .  string(s:save_globals[a:option])
	execute 'let &g:' . a:option '=' string(s:save_globals[a:option])
	unlet s:save_globals[a:option]
    endif
endfunction

function! GlobalOptions#SetBufferLocal( option, value )
    call s:Push(a:option, a:value)

    execute 'augroup b_' . a:option
	execute printf('autocmd! BufEnter <buffer> call <SID>Push(%s, %s)', string(a:option), string(a:value))
	execute printf('autocmd! BufLeave <buffer> call <SID>Pop(%s)', string(a:option))
    augroup END
endfunction
function! GlobalOptions#ClearBufferLocal( option )
    silent! execute 'autocmd! b_' . a:option '* <buffer>'

    call s:Pop(a:option)
endfunction
function! GlobalOptions#GetBufferLocals()
    return filter(keys(s:save_globals), 'exists(printf("#b_%s#BufEnter#<buffer>", v:val))')
endfunction


function! s:SetGlobalWindowsOptions()
    if ! exists('w:GlobalWindowOptions')
	return
    endif

    for l:option in keys(w:GlobalWindowOptions)
	call s:Push(l:option, w:GlobalWindowOptions[l:option])
    endfor
endfunction
function! s:RestoreGlobalWindowsOptions()
    if ! exists('w:GlobalWindowOptions')
	return
    endif

    for l:option in keys(w:GlobalWindowOptions)
	call s:Pop(l:option)
    endfor
endfunction
function! GlobalOptions#SetWindowLocal( option, value )
    call s:Push(a:option, a:value)

    if ! exists('w:GlobalWindowOptions')
	let w:GlobalWindowOptions = {}
    endif
    let w:GlobalWindowOptions[a:option] = a:value

    if ! exists('#GlobalWindowOptions#WinEnter')
	augroup GlobalWindowOptions
	    autocmd! WinEnter * call <SID>SetGlobalWindowsOptions()
	    autocmd! WinLeave * call <SID>RestoreGlobalWindowsOptions()
	augroup END
    endif
endfunction
function! GlobalOptions#ClearWindowLocal( option )
    unlet! w:GlobalWindowOptions[a:option]

    call s:Pop(a:option)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
