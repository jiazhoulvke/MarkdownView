#!/usr/bin/env python
#coding=utf8

import os,sys
from bottle import Bottle,run,static_file,request

app = Bottle()
app_path = sys.argv[1]
port = sys.argv[2]
css = sys.argv[3]
os.chdir(app_path)

@app.route('/')
def index():
    f = open('mdv.html')
    tpl = f.read()
    f.close()
    html = tpl.replace('#css#',css)
    return  html

@app.route('/quit')
def quit():
    pid = os.getpid()
    os.system('kill -s 9 ' + str(pid))

@app.route('/static/<filename>')
def static(filename):
    return static_file(filename,root = app_path)

run(app, host='localhost', port=str(port))
