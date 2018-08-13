# TableWebDemo
TableView 嵌套 WebView ，自适应屏幕宽度时三种 获取WebView真实高度方案。

- 此文读者：iOS 开发者
- 此文深度：粗浅
- 此文目的：解决 TableView 嵌套 WKWebView 高度问题
- 环境配置：Xcode10.0  &  macOS10.13.6  &   弱网环境



#### 前言

项目做多了，难免会有些需要和富文本打交道地方。展示一个富文本可以使用多种技术方案，不过多个方案之间各有自己的特性，这就需要开发人员进行技术的筛选。因本司编辑员常用网页样式，故而一些长篇的图文当中就需要 WebView 作为容器进行展示了。

如果展示是单纯的H5介绍页，使用一个纯 WebView 进行展示是非常合适的。不过当展示界面混合了 Native 控件，事情就变得不太容易起来。通常这样的页面同新闻的详情页一样，一个 TableView 中嵌套了包含 WebView 的 Cell 或 TableHeaderView，且要求整个 TableView 滑动起来自然 & 连贯。

+ 连贯，即要求 TableView 整体内容不能有截断，所以 TableView 中的各个部分要求自适应其高度；
+ 自然，即要求 TableView 在滑动的时候内容随着操作手势明确地上下滚动 不能出现掉帧、卡顿现象，所以 耗时操作 &  响应事件 就需要格外关注；
+ 轻巧，即要求 实现方式较为简便，便于其他开发者的维护；



#### 准备

我们需要创建一个类似新闻详情页的[Demo](https://github.com/YinZhenJob/TableWebDemo)：

+ 主页头部展示 HTML ，宽度与屏幕宽度一致，高度随内容需要完全展开；
+ 尾部是推荐文章的单元，点击该单元可以切换头部的内容，就像下图一样。



![主页面](./detail.png "主页面")



其详情页的层级如下：（已上传到GitHub，为了便于方案演变，本人随开发做了 commit 记录，读者可根据个人需求在各个 commit 版本中切换）

+ TableView
  + WebCell：用于 HTML 展示；
  + SectionCell：用于 模块标题 展示；
  + ArticleCell：用于 推荐单元 展示；
+ ToolView
  + 手势点击事件



#### 基础版：

> 类型：纯文本		
>
> 参考：《人间失格》单元

详情页展示的是纯文本，我们仅需在 WebViw 代理`webView(_, didFinish)`方法通过执行`document.body.scrollHeight`  JS代码注入获取文档高度，再将高度反馈给 TableView 进行刷新即可，该高度即为文档渲染的正确高度。

```
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    	// 获取 HTML 文档高度
        webView.evaluateJavaScript("document.body.scrollHeight") { (heightValue, error) in
            guard let height = heightValue as? CGFloat else { return }
            self.heightAction?(height) 
        }
}
```

请参考[Demo](https://github.com/YinZhenJob/TableWebDemo)中「基础版」commit 节点。



#### 观察者模式：

> 类型：少量图文混排	
>
> 参考：《迟暮》单元

当详情页展示的是少量的图文混排后，因为图片的加载是一件耗时操作的事情，我们通常将其设定为懒加载模式，当页面内的资源加载完毕后我们再获取其高度，才为正确的文档高度。所以在`webView(_, didFinish)`里获取其高度也不是准确的，该代理方法是 WebView 载入 HTML 文档完成后的回调，并不等于该 HTML 完全渲染完后的回调。



1. ##### contentSize 方法

根据以上判断，我们需要捕捉 HTML 渲染变化的信号。而 HTML 渲染动作直接影响到的是 WebView  `scrollView.contentSize` 属性，每当该值发生变化代表的是当前 HTML文档 已渲染到的位置。

我们可以使用**观察者模式**来监听这个属性的变化，当该属性发生变化时我们需要及时调整容器的高度并将其反映给 TableView 进行刷新。

```
fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let web    = WKWebView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 100), configuration: config)
        web.navigationDelegate = self
        web.scrollView.isScrollEnabled = false
        web.translatesAutoresizingMaskIntoConstraints = false
        // 添加观察者监听 scrollView.contentSize 属性
        web.addObserver(self, forKeyPath: "scrollView.contentSize", options: .new, context: nil)
        return web
}()
    
/// 监听 scrollView.contentSize 属性
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "scrollView.contentSize", let newSize = change?[.newKey] as? CGSize 			{
            print("new size: \(newSize)")
            self.heightAction?(newSize.height)
        }
}

deinit {
        webView.stopLoading()
        webView.removeObserver(self, forKeyPath: "scrollView.contentSize")
    }
```



1. ##### loading 方法

同 `contentSize` 一样，我们也可以使用更高效的 `loading` 来进行监控，该属性用于表达 WebView 的加载状态， Apple 文档中对 `isLoading` 属性的描述如下：

> A Boolean value indicating whether the view is currently loading content.
>
>  @discussion @link WKWebView @/link is key-value observing (KVO) compliant  for this property.

修改后的代码，如下：

```
fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let web    = WKWebView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 100), configuration: config)
        web.navigationDelegate = self
        web.scrollView.isScrollEnabled = false
        web.translatesAutoresizingMaskIntoConstraints = false
        // 监听 webView 加载的动作
        web.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        return web
    }()
    
    /// 监听 scrollView.contentSize & loading
override func observeValue(forKeyPath keyPath: String?, 
						   of object: Any?, 
						   change: [NSKeyValueChangeKey : Any]?, 
						   context: UnsafeMutableRawPointer?) {
						   
        if keyPath == "loading"{
            webView.evaluateJavaScript("document.body.scrollHeight") 
            { (heightValue, error) in
                guard let height = heightValue as? CGFloat else { return }
                print("Web loading Height: \(height)")
                self.heightAction?(height)
            }
        }
    }
    
    deinit {
        webView.stopLoading()
        webView.removeObserver(self, forKeyPath: "loading")
    }
```

 

通过打印这两个观察者属性的调用动作，可以发现 contentSize 比 loading 调用的次数多，且在滚动 TableView 的时候 contentSize 是随即更新无论是否真有变化，而 loading 自加载完成后不再调用，两者计算的高度值一样。

如果使用观察者模式的话，建议选用 `loading` 模式：

其一 监听加载的动作更符合**渲染状态发生**这一事实；

其二 如果被认定为已加载完成 contentSize 就不会再变，无需持续观察。

虽然网络稍好的时候用以上方法均可以实现获取文档的正确高度，但一旦网络极差的情况下上面的方式都失效了。

请参考[Demo](https://github.com/YinZhenJob/TableWebDemo)中「观察者模式」commit 节点。

#### * JS 监听：

记得上周五下班回家在地铁上开开心心等待第二天的 ChinaJoy，拿起小手机看看资讯消息，然后一条老板的微信消息@me，老板给我截了图~某详情页展示不全。虽然对这个问题熟悉得不能再熟悉也清楚要做什么，但还是为之一怔，因为和老板交流的不多（有时候他看着我，但目光已经透过了我到达后面的同事），为了不打破被老板忽略的角落形象，决定好好想想策略。



> 类型：大量图文混排
>
> 参考：《它们一边鄙视，一边用自己的方式照顾我们》单元

经过了之前的技术探索，觉得从 WebView 中找到监察 HTML 页面渲染完成的状态并不可靠，如果 HTML能够主动发送消息给我就好了。

按照这种想法，搜索了 「HTML 加载完成事件、HTML 图片懒加载完成事件……」，最终查到，在 HTML DOM 中 Event 有个函数 [onload](http://www.w3school.com.cn/jsref/event_onload.asp) 是用于**一张页面或一幅图像完成加载**时所执行的，我们需要监听所有的 `img`标签 或 `body`标签，然后在这个方法里发个消息给 WebKit 然后进行拦截即可。

接下来我们要做两件事：

1. 在 WebView 里注册一个方法，用以接收 HTML DOM 的事件；
2. 在 HTML 里补充 JS 脚本，用以发送消息给 WebView ；



##### 1. 在 WebView 里注册一个方法

> 1. 配置 WKWebViewConfiguration ，为其注册一个 ScriptMessageHandler ；
> 2. 实现 WKScriptMessageHandler 代理方法，拦截 你所注册的 ScriptMessageHandler；

```
fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
            config.preferences.javaScriptEnabled = true
            // 在此注册 JS 发送对象的函数名
            config.userContentController.add(self, name: "imagLoaded")
        let web    = WKWebView(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 100), configuration: config)
        web.navigationDelegate = self
        web.scrollView.isScrollEnabled = false
        web.translatesAutoresizingMaskIntoConstraints = false
        return web
}()


func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "imagLoaded", let height = message.body as? CGFloat {
            heightAction?(height)
        }
}
```



##### 2. 添加以下 JS 代码在 \</ body> 标签之后

> 1. 使用 `document.getElementsByTagName('img')` 会获取 DOM 目录下所有的 img 标签；
> 2. 使用 `window.webkit.messageHandlers.<你所注册的方法名>.postMessage('数据消息')` 给 webkit 发送消息；

```
<script type="text/javascript">
    
    let imgArr = document.getElementsByTagName('img');
    for (var i = 0; i <= imgArr.length - 1; i++) {
        (imgArr[i]).onload = function() { // 加载完成后给 webkit 发送通知
            let height = document.body.scrollHeight;
            window.webkit.messageHandlers.imagLoaded.postMessage(height);
        }
    }
    
</script>
```



本文仅作为实际工程的应用，不涉及任何知识体系，想了解更多，请查看 [WebKit](https://github.com/WebKit/webkit) 的开源代码 ╮(╯_╰)╭。

本人博文地址：yinzhen.tech