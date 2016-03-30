" MarkdownView: 让Vim变身成可视化的Markdown编辑器
" Author:       jiazhoulvke
" Email:        jiazhoulvke@gmail.com 
" Blog:         http://www.jiazhoulvke.com 
" Date:         2013-01-23 01:09:11
" Update:       2014-09-05
" Version:      0.2
"------------------------------------------------

"------------------------------------------------
" Init:{{{1
"------------------------------------------------
if exists("g:markdownview_loaded")
    finish
endif
let g:markdownview_loaded=1
if !exists('g:markdownview_css')
    let g:markdownview_css = 'github.css'
endif
if !exists('g:markdownview_port')
    let g:markdownview_port = '9527'
endif
if !exists('g:markdownview_viewer')
    let g:markdownview_viewer = 'x-www-browser'
endif


"------------------------------------------------
" Functions:{{{1
"------------------------------------------------
let s:markdownview_sfile = expand('<sfile>')
python << EOA
#coding=utf8
import httplib,urllib,os,vim,markdown
port = vim.eval('g:markdownview_port')
css = vim.eval('g:markdownview_css')
sfile = vim.eval('s:markdownview_sfile')
sdir = os.path.dirname(sfile)
httpClient = httplib.HTTPConnection('localhost', int(port))
EOA

function! MarkdownView()
let b:markdownview_started = 1
python << EOA
pyfile = os.path.join(sdir,'MarkdownView.py')
os.system('python ' + pyfile + ' ' + sdir + ' ' + port + ' ' + css + ' >/dev/null &')
viewer = vim.eval('g:markdownview_viewer')
if viewer == 'webkit':
    import webkit,gtk
    win=gtk.Window(gtk.WINDOW_TOPLEVEL)
    win.set_size_request(640,480)
    win.connect('destroy',gtk.main_quit)
    wv = webkit.WebView()
    sw = gtk.ScrolledWindow()
    sw.add(wv)
    win.add(sw)
    win.show_all()
    wv.open('http://localhost:'+port)
    gtk.main()
else:
    os.system(viewer + ' http://localhost:'+port+'&')
EOA
endfunction

function! MarkdownView_Quit()
if exists('b:markdownview_started')
    call system('wget http://localhost:'.g:markdownview_port.'/quit')
endif
let b:markdownview_started = 0
endfunction

function! MarkdownView_Update()
if !exists('b:markdownview_started')
    return
endif
let lines = getline(1,'$')
python << EOA
#coding=utf-8
reload(sys)
sys.setdefaultencoding('UTF-8')
curline = int(vim.eval('line(".")'))
lines = vim.eval('lines')
lines.append('')
lines[curline-1] = '<span id="target"></span>\n' + lines[curline-1]
content = markdown.markdown('\n'.join(lines))
cfile = os.path.join(sdir,'content.html')
contentfile = open(cfile,'w')
contentfile.write(content)
contentfile.close()
EOA
endfunction

"------------------------------------------------
" Bind:{{{1
"------------------------------------------------
autocmd! CursorMoved,CursorMovedI,CursorHold *.md call MarkdownView_Update()
autocmd! BufDelete,BufUnload,VimLeave *.md call MarkdownView_Quit()
command! MarkdownView call MarkdownView()
command! MarkdownViewQuit call MarkdownView_Quit()
