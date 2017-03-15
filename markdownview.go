package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/pquerna/ffjson/ffjson"
	"github.com/russross/blackfriday"
)

var (
	appPath         string
	port            int
	httpServerErr   chan error
	httpServerPort  chan int
	socketServerErr chan error
	browerErr       chan error
	httpPort        int
	done            chan bool
	render          blackfriday.Renderer
	mdResult        string
	stylePath       string
	logger          *os.File
	brower          = "x-www-browser"
)

//Body 传输的数据
type Body struct {
	Action  string `json:"action"`
	Content string `json:"content"`
}

type pos struct {
	X int
	Y int
}

func init() {
	httpServerErr = make(chan error)
	httpServerPort = make(chan int)
	socketServerErr = make(chan error)
	browerErr = make(chan error)

	render = blackfriday.HtmlRenderer(0, "", "")

	flag.IntVar(&port, "port", 9527, "服务器端口")
	flag.StringVar(&stylePath, "style", "github.css", "样式文件地址,可以是绝对地址也可以是相对地址")
}

func main() {
	flag.Parse()
	var err error

	appPath = filepath.Dir(os.Args[0])
	os.Chdir(appPath)

	if port == 0 {
		println("端口不能为空")
		return
	}
	if stylePath == "" {
		println("样式文件路径不能为空")
		return
	}
	if stylePath[0] == '~' {
		stylePath = "$HOME" + stylePath[1:]
	}
	_, err = os.Stat(stylePath)
	if err != nil && os.IsNotExist(err) {
		println("找不到样式文件:", stylePath)
		return
	}

	//获取网页内容
	done = make(chan bool)
	go socketServer(port)
	go httpServer()
	go startBrower()
	select {
	case err := <-httpServerErr:
		log.Fatal(err)
	case err := <-socketServerErr:
		log.Fatal(err)
	case err := <-browerErr:
		log.Fatal(err)
	case <-done:
		println("exit")
	}
}

//socketServer 启动一个套接字服务器
func socketServer(port int) {
	var listener net.Listener
	var err error
	if listener, err = net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port)); err != nil {
		socketServerErr <- err
	}
	defer listener.Close()
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go func(conn net.Conn) {
			defer conn.Close()
			msg, err := ioutil.ReadAll(conn)
			if err != nil {
				return
			}
			if string(msg) == "" {
				return
			}
			var body Body
			if err := ffjson.Unmarshal(msg, &body); err != nil {
				return
			}
			switch body.Action {
			case "quit":
				done <- true
			case "parse":
				mdResult = string(blackfriday.Markdown([]byte(body.Content), render,
					blackfriday.EXTENSION_TABLES|
						blackfriday.EXTENSION_HARD_LINE_BREAK|
						blackfriday.EXTENSION_AUTOLINK|
						blackfriday.EXTENSION_FENCED_CODE|
						blackfriday.EXTENSION_FOOTNOTES|
						blackfriday.EXTENSION_STRIKETHROUGH))
			}
		}(conn)
	}
}

//httpServer 启动一个http服务器
func httpServer() {
	var listener net.Listener
	var err error
	if listener, err = net.Listen("tcp", "127.0.0.1:0"); err != nil {
		httpServerErr <- err
		return
	}
	httpServerPort <- listener.Addr().(*net.TCPAddr).Port
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=UTF-8")
		http.ServeFile(w, r, filepath.Join(appPath, "index.html"))
	})
	http.HandleFunc("/style.css", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/css;charset=UTF-8")
		http.ServeFile(w, r, stylePath)
	})
	http.HandleFunc("/content", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=UTF-8")
		w.Write([]byte(mdResult))
	})
	if err := http.Serve(listener, nil); err != nil {
		httpServerErr <- err
	}
}

//startBrower 启动浏览器
func startBrower() {
	port := <-httpServerPort
	var cmd *exec.Cmd
	cmd = exec.Command("sh", "-c", fmt.Sprintf("%s http://127.0.0.1:%d", brower, port))
	fmt.Println("HttpPost:", port)
	if err := cmd.Start(); err != nil {
		browerErr <- err
	}
}
