" GlobalOptions/Command.vim: Implementation for :Set...Local commands.
"
" DEPENDENCIES:
"   - GlobalOptions.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	02-Jan-2013	file creation

function! s:ErrorMsg( text )
    let v:errmsg = a:text
    echohl ErrorMsg
    echomsg v:errmsg
    echohl None
endfunction

function! s:OptionCheck( parsedOption )
    if ! exists('&' . a:parsedOption[1])
	let a:parsedOption[0] = 'invalid'
    endif

    return a:parsedOption
endfunction
function! s:Unescape( expr )
    return substitute(a:expr, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\([\\ ]\)', '\1', 'g')
endfunction
function! s:Parse( option )
    if a:option =~# '^no\a\+$'
	return s:OptionCheck(['set', a:option[2:], '0'])
    elseif a:option =~# '^\a\+$'
	return s:OptionCheck(['set', a:option, '1'])
    elseif a:option =~# '^\a\+?$'
	return s:OptionCheck(['list', a:option[0:-2], ''])
    elseif a:option =~# '^\a\+<$'
	return s:OptionCheck(['clear', a:option[0:-2], ''])
    elseif a:option =~# '^\a\+='
	let l:pos = stridx(a:option, '=')
	return s:OptionCheck(['set', strpart(a:option, 0, l:pos), s:Unescape(strpart(a:option, l:pos + 1))])
    else
	return ['invalid', a:option, '']
    endif
endfunction
function! s:ParseOptions( options )
    let l:options = split(a:options, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<! ')
    return map(l:options, 's:Parse(v:val)')
endfunction


function! s:HasBufferLocalOption( option )
    return index(GlobalOptions#GetBufferLocals(), a:option) != -1
endfunction
function! s:ListBufferLocal( option )
    execute 'let l:value = &g:' . a:option
    echo printf('%s=%s', a:option, l:value)
endfunction
function! s:ListBufferLocals()
    for l:option in sort(GlobalOptions#GetBufferLocals())
	call s:ListBufferLocal(l:option)
    endfor
endfunction
function! GlobalOptions#Command#BufferLocal( options )
    if empty(a:options)
	call s:ListBufferLocals()
    else
	for [l:action, l:option, l:value] in s:ParseOptions(a:options)
	    if l:action ==# 'list'
		if s:HasBufferLocalOption(l:option)
		    call s:ListBufferLocal(l:option)
		endif
	    elseif l:action ==# 'set'
		call GlobalOptions#SetBufferLocal(l:option, l:value)
	    elseif l:action ==# 'clear'
		if ! s:HasBufferLocalOption(l:option)
		    call s:ErrorMsg(printf('No buffer-local option: %s', l:option))
		    return
		endif

		call GlobalOptions#ClearBufferLocal(l:option)
	    elseif l:action ==# 'invalid'
		call s:ErrorMsg(printf('Unknown option: %s', l:option))
		return
	    else
		throw 'ASSERT: Invalid action ' . string(l:action)
	    endif
	endfor
    endif
endfunction


function! s:ListWindowLocal( option )
    if ! exists('w:GlobalWindowOptions') || ! has_key(w:GlobalWindowOptions, a:option)
	return
    endif

    echo printf('%s=%s', a:option, w:GlobalWindowOptions[a:option])
endfunction
function! s:ListWindowLocals()
    for l:option in sort(exists('w:GlobalWindowOptions') ? keys(w:GlobalWindowOptions) : [])
	call s:ListWindowLocal(l:option)
    endfor
endfunction
function! GlobalOptions#Command#WindowLocal( options )
    if empty(a:options)
	call s:ListWindowLocals()
    else
	for [l:action, l:option, l:value] in s:ParseOptions(a:options)
	    if l:action ==# 'list'
		call s:ListWindowLocal(l:option)
	    elseif l:action ==# 'set'
		call GlobalOptions#SetWindowLocal(l:option, l:value)
	    elseif l:action ==# 'clear'
		if ! exists('w:GlobalWindowOptions') || ! has_key(w:GlobalWindowOptions, l:option)
		    call s:ErrorMsg(printf('No window-local option: %s', l:option))
		    return
		endif

		call GlobalOptions#ClearWindowLocal(l:option)
	    elseif l:action ==# 'invalid'
		call s:ErrorMsg(printf('Unknown option: %s', l:option))
		return
	    else
		throw 'ASSERT: Invalid action ' . string(l:action)
	    endif
	endfor
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
