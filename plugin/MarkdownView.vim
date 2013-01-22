" MarkdownView: 让Vim变身成可视化的Markdown编辑器
" Author:       jiazhoulvke
" Email:        jiazhoulvke@gmail.com 
" Blog:         http://www.jiazhoulvke.com 
" Date:         2013-01-23 01:09:11
" Version:      0.1
"------------------------------------------------

"------------------------------------------------
" Init:{{{1
"------------------------------------------------
if exists("g:markdownview_loaded")
    finish
endif
let g:markdownview_loaded=1

"------------------------------------------------
" Functions:{{{1
"------------------------------------------------
python << EOA
import os
import vim
EOA

let s:markdownview_sfile = expand('<sfile>')

function! MarkdownView()
python << EOA
sfile = vim.eval('s:markdownview_sfile')
sdirname = os.path.dirname(sfile)
pyfile = os.path.join(sdirname,'MarkdownView.py')
b = vim.current.buffer
dirname = os.path.dirname(b.name)
fname = os.path.basename(b.name).rsplit('.',1)[0] + '_mdv.html'
frp = os.path.join(dirname,fname)
os.system('python ' + pyfile + ' ' + frp + '&')
EOA
endfunction

function! MarkdownView_Update()
python << EOA
import markdown
import webkit
b = vim.current.buffer
r = b.range(1,len(b))
html = '<html><meta http-equiv="refresh" content="1" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><body>' + markdown.markdown('\n'.join(r)) + '</body></html>'
dirname = os.path.dirname(b.name)
fname = os.path.basename(b.name).rsplit('.',1)[0] + '_mdv.html'
frp = os.path.join(dirname,fname)
f = open(frp,'w')
f.write(html)
f.close()
EOA
endfunction

"------------------------------------------------
" Commands:{{{1
"------------------------------------------------
command! MarkdownView call MarkdownView()
autocmd! CursorMoved,CursorMovedI,CursorHold *.md call MarkdownView_Update()

" vim: ts=4 nowrap fdm=marker foldcolumn=1 filetype=vim
