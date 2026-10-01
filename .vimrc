" Keep Vim's stock defaults (syntax highlighting etc.); creating a ~/.vimrc
" otherwise switches them off.
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" WSL: back the + and * registers with the Windows clipboard. This Vim
" (vim.basic) has no built-in clipboard, but it does have +clipboard_provider,
" which lets us plug in external commands. win32yank handles UTF-8 and line
" endings properly; clip.exe / powershell.exe are slower fallbacks.
if has('clipboard_provider')
  if executable('win32yank.exe')
    let s:copy_cmd  = 'win32yank.exe -i --crlf'
    let s:paste_cmd = 'win32yank.exe -o --lf'
  elseif executable('clip.exe')
    let s:copy_cmd  = 'clip.exe'
    let s:paste_cmd = 'powershell.exe -NoProfile -NoLogo -Command'
          \ . ' "[Console]::OutputEncoding = [Text.Encoding]::UTF8; Get-Clipboard -Raw"'
  endif

  if exists('s:copy_cmd')
    function! s:WinClipCopy(reg, type, lines) abort
      call system(s:copy_cmd, join(a:lines, "\n") . (a:type[0] ==# 'V' ? "\n" : ''))
    endfunction

    function! s:WinClipPaste(reg) abort
      let l:text = substitute(system(s:paste_cmd), '\r', '', 'g')
      " Text ending in a newline was most likely copied as whole lines.
      let l:type = l:text =~# '\n$' ? 'V' : 'v'
      return [l:type, split(substitute(l:text, '\n$', '', ''), "\n", 1)]
    endfunction

    let v:clipproviders['wsl'] = {
          \ 'copy':  {'+': function('s:WinClipCopy'),  '*': function('s:WinClipCopy')},
          \ 'paste': {'+': function('s:WinClipPaste'), '*': function('s:WinClipPaste')},
          \ }
    set clipmethod^=wsl
    " Plain y/d/p use the Windows clipboard.
    set clipboard=unnamedplus
  endif
endif

set ignorecase 
set smartcase

set tabstop=4
set shiftwidth=4
