import UIKit
import WebKit

/// https://github.com/keitaoouchi/MarkdownView/

open class MarkdownView: UIView {

    private var webView: WKWebView?
    
    public var isScrollEnabled: Bool = true {
        didSet {
            webView?.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public var onTouchLink: ((URLRequest) -> Bool)?
    
    public var onRendered: ((CGFloat) -> Void)?
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init (frame: CGRect) {
        super.init(frame : frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        Log("webView bounds = \(webView?.bounds)")
        webView?.frame.size = bounds.size
        webView?.center = center
    }
    
    public func load(markdown: String?, enableImage: Bool = true) {
        guard let markdown = markdown else { return }
        
        let bundle = Bundle.main//(for: MarkdownView.self)
        
        var htmlURL: URL?
        if bundle.bundleIdentifier?.hasPrefix("org.cocoapods") == true {
            Log("bundle 1")
            htmlURL = bundle.url(forResource: "index",
                                 withExtension: "html",
                                 subdirectory: "MarkdownView.bundle")
        } else {
            Log("bundle 2")
            htmlURL = bundle.url(forResource: "index",
                                 withExtension: "html")
        }
        
        Log("url = \(htmlURL)")
        
        if let url = htmlURL {
            let templateRequest = URLRequest(url: url)
            Log("templateRequest = \(templateRequest)")
            let escapedMarkdown = self.escape(markdown: markdown) ?? ""
            let imageOption = enableImage ? "true" : "false"
            let script = "window.showMarkdown('\(escapedMarkdown)', \(imageOption));"
            let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            
            let controller = WKUserContentController()
            controller.addUserScript(userScript)
            
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = controller
            
            Log("bounds = \(self.bounds)")
            
            let wv = WKWebView(frame: self.bounds, configuration: configuration)
            wv.scrollView.isScrollEnabled = self.isScrollEnabled
            wv.translatesAutoresizingMaskIntoConstraints = false
            wv.navigationDelegate = self
            addSubview(wv)
            //wv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            //wv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            //wv.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            //wv.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            wv.backgroundColor = self.backgroundColor
            
            self.webView = wv
            
            wv.load(templateRequest)
        } else {
            // TODO: raise error
        }
    }
    
    private func escape(markdown: String) -> String? {
        return markdown.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
    }

}

extension MarkdownView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let script = "document.body.offsetHeight;"
        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let _ = error { return }
            
            if let height = result as? CGFloat {
                self?.onRendered?(height)
                Log("height = \(height)")
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if let onTouchLink = onTouchLink, onTouchLink(navigationAction.request) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        default:
            decisionHandler(.allow)
        }
        
    }

}
