" MarkdownView: 让Vim变身成可视化的Markdown编辑器
" Author:       jiazhoulvke
" Email:        jiazhoulvke@gmail.com 
" Blog:         http://www.jiazhoulvke.com 
" Version:      0.99
"------------------------------------------------

"------------------------------------------------
" Init:{{{1
"------------------------------------------------
if exists("g:markdownview_loaded")
    finish
endif
if !has('channel') 
    finish
endif
if !has('job') 
    finish
endif
if !has('timers') 
    finish
endif
let g:markdownview_loaded=1
if !exists('g:markdownview_css')
    let g:markdownview_css='github.css'
endif
if !exists('g:markdownview_port')
    let g:markdownview_port='9527'
endif
if !exists('g:markdownview_timer')
    let g:markdownview_timer=500
endif

"------------------------------------------------
" Functions:{{{1
"------------------------------------------------
let s:markdownview_sfile=expand('<sfile>')
let s:markdownview_path=strpart(s:markdownview_sfile,0,strridx(s:markdownview_sfile,'/',strridx(s:markdownview_sfile,'/')-1))

function! MarkdownView()
    if !exists('b:markdownview_started') || b:markdownview_started==0
        let b:markdownview_job=job_start([s:markdownview_path.'/markdownview','-port',g:markdownview_port,'-style',g:markdownview_css])
        let status=job_status(b:markdownview_job)
        if status!='run'
            echomsg 'markdownview启动失败'
            return
        endif
        sleep 3
        let b:socket_channel=ch_open('127.0.0.1:'.g:markdownview_port)
        if ch_status(b:socket_channel) == 'fail'
            echomsg '尝试建立连接失败'
            return
        endif
        let b:timer=timer_start(g:markdownview_timer, 'MarkdownView_Update', {'repeat': -1})
        autocmd! BufDelete,BufUnload,VimLeave <buffer> * call MarkdownView_Quit()
        let b:markdownview_started=1
    endif
endfunction

function! MarkdownView_Quit()
    if exists('b:markdownview_started') && b:markdownview_started==1
        call timer_stop(b:timer)
        call job_stop(b:markdownview_job)
        call ch_sendraw(b:socket_channel, json_encode({'action': 'quit'}))
        call ch_close(b:socket_channel)
    endif
    let b:markdownview_started = 0
endfunction

function! MarkdownView_OpenBrowser()
    if !exists('b:MarkdownView_started') || b:MarkdownView_started==0
        return
    endif
    let channel=ch_open('127.0.0.1:'.g:markdownview_port)
    call ch_sendraw(channel, json_encode({'action':'openbrowser'}))
    call ch_close(channel)
endfunction

function! MarkdownView_Update(timer)
    if !exists('b:markdownview_started') || b:markdownview_started==0
        return
    endif
    let lines=getline(1,'$')
    let content=join(lines,"\n")
    if content==''
        return
    endif
    let channel=ch_open('127.0.0.1:'.g:markdownview_port)
    call ch_sendraw(channel, json_encode({'action': 'parse', 'content': content}))
    call ch_close(channel)
endfunction

"------------------------------------------------
" Bind:{{{1
"------------------------------------------------
command! MarkdownView call MarkdownView()
command! MarkdownViewQuit call MarkdownView_Quit()
command! MarkdownViewOpenBrowser call MarkdownView_OpenBrowser()

" vim: foldmethod=marker
