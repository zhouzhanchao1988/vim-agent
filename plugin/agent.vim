" agent.vim — 在 Vim 里打开 Cursor Agent 终端。
"
"   :Agent              当前标签右侧分屏，宽度约三分之一
"   :AgentTab           放到新建标签，已有会话会移过去
"   :AgentHide          在代码窗口隐藏 Agent，进程继续跑
"   :Agent 参数         只在第一次启动时传给 agent，例如 :Agent --continue
"   空格 a              与 :Agent 相同（编辑区和 Terminal-Normal 下）
"
" 说明: :help Agent
" 可执行文件默认 ~/.local/bin/agent，也可在 vimrc 里指定:
"   let g:agent_exe = '/path/to/agent'

if exists('g:loaded_agent')
  finish
endif
let g:loaded_agent = 1

if !has('terminal')
  finish
endif

function! s:AgentWidth() abort
  let l:third = (&columns + 2) / 3
  let l:width = max([l:third, 48])
  let l:limit = max([(&columns * 2) / 5, 1])
  if l:width > l:limit
    let l:width = max([l:third, 24])
  endif
  return l:width
endfunction

function! s:AgentExe() abort
  if exists('g:agent_exe') && executable(g:agent_exe)
    return g:agent_exe
  endif
  let l:path = expand('~/.local/bin/agent')
  if executable(l:path)
    return l:path
  endif
  return 'agent'
endfunction

function! s:IsAgentWin(winnr) abort
  return getwinvar(a:winnr, 'agent_term', 0) || getbufvar(winbufnr(a:winnr), 'agent_term', 0)
endfunction

function! s:FindAgentWindow() abort
  let l:i = 1
  while l:i <= winnr('$')
    if s:IsAgentWin(l:i)
      return l:i
    endif
    let l:i += 1
  endwhile
  return 0
endfunction

function! s:FindAgentBuffer() abort
  for l:nr in term_list()
    if getbufvar(l:nr, 'agent_term', 0) && term_getstatus(l:nr) =~# 'running'
      return l:nr
    endif
  endfor
  return 0
endfunction

function! s:AgentApplyWidth(winnr) abort
  if a:winnr < 1 || a:winnr > winnr('$')
    return
  endif
  let l:width = s:AgentWidth()
  if winwidth(a:winnr) == l:width
    return
  endif
  let l:cur = winnr()
  noautocmd execute a:winnr . 'wincmd w'
  noautocmd execute 'vertical resize ' . l:width
  setlocal winfixwidth
  if l:cur != winnr() && l:cur <= winnr('$')
    noautocmd execute l:cur . 'wincmd w'
  endif
endfunction

function! s:AgentMark() abort
  let b:agent_term = 1
  let w:agent_term = 1
  setlocal nocursorline nocursorcolumn
  setlocal nonumber norelativenumber
  setlocal signcolumn=no
  setlocal colorcolumn=
  setlocal scrolloff=0
  " 回滚时只按一次 Ctrl-\ 进入 Terminal-Normal，不必再按 Ctrl-N
  tnoremap <buffer> <silent> <C-\> <C-\><C-n>
endfunction

function! s:AgentWindowSetup() abort
  call s:AgentMark()
  setlocal winfixwidth
  execute 'vertical resize ' . s:AgentWidth()
endfunction

function! s:FindAgentTab() abort
  let l:t = 1
  while l:t <= tabpagenr('$')
    for l:bnr in tabpagebuflist(l:t)
      if getbufvar(l:bnr, 'agent_term', 0)
        return l:t
      endif
    endfor
    let l:t += 1
  endwhile
  return 0
endfunction

function! s:AgentStart(args) abort
  let l:argv = [s:AgentExe()]
  if !empty(a:args)
    let l:argv += split(a:args)
  endif
  let l:nr = term_start(l:argv, {
        \ 'curwin': 1,
        \ 'term_name': 'agent',
        \ 'term_finish': 'close',
        \ 'term_kill': 'term',
        \ 'cwd': getcwd(),
        \ 'env': {'TERM': 'xterm-256color'},
        \ })
  if l:nr == 0
    bwipeout
    echoerr '无法启动 agent'
    return 0
  endif
  call s:AgentMark()
  call term_wait(l:nr, 100)
  call s:AgentEnterJob()
  call s:AgentMouse(1)
  return l:nr
endfunction

" 占满新建标签，不再套用分屏时的三分之一宽度
function! s:AgentShowInTab() abort
  setlocal nowinfixwidth
  call s:AgentMark()
  call s:AgentEnterJob()
  call s:AgentMouse(1)
endfunction

function! s:AgentTab(args) abort
  let l:win = s:FindAgentWindow()
  if l:win > 0
    execute l:win . 'wincmd w'
    if winnr('$') > 1
      wincmd T
    endif
    call s:AgentShowInTab()
    return
  endif

  let l:tab = s:FindAgentTab()
  if l:tab > 0
    execute 'tabnext ' . l:tab
    let l:win = s:FindAgentWindow()
    if l:win > 0
      execute l:win . 'wincmd w'
    endif
    call s:AgentShowInTab()
    return
  endif

  let l:nr = s:FindAgentBuffer()
  if l:nr > 0
    execute 'tab sbuffer ' . l:nr
    call s:AgentShowInTab()
    return
  endif

  tabnew
  call s:AgentStart(a:args)
endfunction

" 从任意窗口隐藏 Agent。:hide 会关掉那个分屏或标签，缓冲区和进程保留。
function! s:AgentHide() abort
  let l:tab = 1
  while l:tab <= tabpagenr('$')
    let l:w = 1
    let l:last = tabpagewinnr(l:tab, '$')
    while l:w <= l:last
      let l:bnr = tabpagebuflist(l:tab)[l:w - 1]
      if getbufvar(l:bnr, 'agent_term', 0)
        if l:last == 1 && tabpagenr('$') == 1
          echomsg 'Agent 是唯一窗口，无法隐藏'
          return
        endif
        let l:back = win_getid()
        execute 'tabnext ' . l:tab
        execute l:w . 'hide'
        if win_id2win(l:back)
          call win_gotoid(l:back)
        endif
        return
      endif
      let l:w += 1
    endwhile
    let l:tab += 1
  endwhile
  echomsg '没有可隐藏的 Agent 窗口'
endfunction

" 命令还在执行时不能用 normal 去滚终端，否则会碰到不可修改缓冲区。
" 等 :Agent 返回、窗口真正处于终端模式后，再滚到末尾并进入 Job。
function! s:AgentEnterJob() abort
  if &buftype !=# 'terminal'
    return
  endif
  let l:status = term_getstatus(bufnr('%'))
  if l:status !~# 'running'
    return
  endif
  call feedkeys("\<C-\>\<C-n>Gi", 'n')
endfunction

function! s:AgentMouse(enable) abort
  if a:enable
    if exists('s:agent_mouse_save')
      return
    endif
    let s:agent_mouse_save = &mouse
    let s:agent_ttymouse_save = &ttymouse
    set mouse=a
    if empty(&ttymouse)
      set ttymouse=sgr
    endif
  elseif exists('s:agent_mouse_save')
    let &mouse = s:agent_mouse_save
    let &ttymouse = s:agent_ttymouse_save
    unlet s:agent_mouse_save
    unlet s:agent_ttymouse_save
  endif
endfunction

function! s:AgentResizeAll() abort
  let l:i = 1
  while l:i <= winnr('$')
    if s:IsAgentWin(l:i)
      call s:AgentApplyWidth(l:i)
    endif
    let l:i += 1
  endwhile
endfunction

function! s:AgentToggle(args) abort
  if s:IsAgentWin(winnr())
    if winnr('$') > 1
      wincmd p
    endif
    return
  endif

  let l:win = s:FindAgentWindow()
  if l:win > 0
    execute l:win . 'wincmd w'
    call s:AgentWindowSetup()
    call s:AgentEnterJob()
    call s:AgentMouse(1)
    return
  endif

  let l:nr = s:FindAgentBuffer()
  if l:nr > 0
    " 宽度不能写在 sbuffer 前面，否则会被当成行范围，缓冲区行数不够时直接 E16
    execute 'botright vertical sbuffer ' . l:nr
    call s:AgentWindowSetup()
    call s:AgentEnterJob()
    call s:AgentMouse(1)
    return
  endif

  execute 'botright vertical ' . s:AgentWidth() . 'new'
  setlocal winfixwidth
  if s:AgentStart(a:args) == 0
    return
  endif
  call s:AgentWindowSetup()
endfunction

command! -nargs=* Agent call s:AgentToggle(<q-args>)
command! -nargs=* AgentTab call s:AgentTab(<q-args>)
command! AgentHide call s:AgentHide()
nnoremap <silent> <leader>a :Agent<CR>
augroup AgentTermSize
  autocmd!
  autocmd VimResized * call s:AgentResizeAll()
  autocmd WinEnter * if get(b:, 'agent_term', 0) | call s:AgentMouse(1) | endif
  autocmd WinLeave * if get(b:, 'agent_term', 0) | call s:AgentMouse(0) | endif
augroup END
