# MarkdownView #

MarkdownView是一个可以让Vim变成所见即所得的Markdown编辑器的插件。

## 依赖 ##

- vim版本>8.0
- has('channel')
- has('job')
- has('timers')
- ~~不再依赖python~~

## 安装 ##

- [Plug](https://github.com/tpope/vim-pathogen) 
`Plug 'jiazhoulvke/MarkdownView'`
- [Vundle](https://github.com/gmarik/vundle)
`Plugin 'jiazhoulvke/MarkdownView'`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
`NeoBundle 'jiazhoulvke/MarkdownView'`
- [Pathogen](https://github.com/tpope/vim-pathogen)
`git clone https://github.com/jiazhoulvke/MarkdownView ~/.vim/bundle/MarkdownView`

**注意:如果你使用的是32位操作系统，需要先安装golang，然后进入插件所在目录执行make。**

本插件在64位Ubuntu16.04上测试通过。

## 使用 ##

1. 打开markdown文件
2. 输入 :MarkdownView
  程序会自动打开你的浏览器

## 配置 ##

- `g:markdownview_port` 插件使用的端口,默认是9527
- `g:markdownview_css` 插件使用的样式文件，默认是'github.css',位于插件所在目录，如果对默认的样式不满意可以自己写
- `g:markdownview_timer` 多久发送一次内容到服务端，默认是500 (单位:毫秒)


## 效果展示 ##

![MarkdownView](https://github.com/jiazhoulvke/MarkdownView/raw/master/MarkdownView.png)
