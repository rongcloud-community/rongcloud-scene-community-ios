//
//  RCSCWKWebVC.swift
//  RCSceneCommunity
//
//  Created by dev on 2022/5/16.
//

import Foundation
import WebKit


class RCSCWKWebVC: UIViewController {
    private  lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.backgroundColor = UIColor.white
        webView.navigationDelegate = self
        return webView
    }()
    private var navTitle: String?
    private var url: String
    
    
    init(_ title: String?, url: String) {
        self.navTitle = title
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebRequest()
    }
    private func setupWebView() {
        self.title = navTitle
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadWebRequest() {
        let urlString = self.url
        if urlString.hasPrefix("http"),let httpUrl = URL(string: urlString) {
            let request = URLRequest(url: httpUrl)
            webView.load(request)
        }else{
            let fileUrl = URL(fileURLWithPath: urlString)
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl)
        }
      
        
    }
    
}


extension RCSCWKWebVC:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webView start")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview didFinish")
    }
}
