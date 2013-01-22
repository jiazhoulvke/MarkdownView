#!/usr/bin/env python
import gtk
import webkit
import sys

win=gtk.Window(gtk.WINDOW_TOPLEVEL)
win.set_size_request(640,480)
win.connect('destroy',gtk.main_quit)

wv = webkit.WebView()
sw = gtk.ScrolledWindow()
sw.add(wv)
win.add(sw)
win.show_all()

fname = sys.argv[1]
html = '<html><meta http-equiv="refresh" content="1" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><body><h2>MarkdownView<h4>by jiazhoulvke</h4></h2></body></html>'
f = open(fname,'w')
f.write(html)
f.close()
wv.open('file://'+fname)

gtk.main()
