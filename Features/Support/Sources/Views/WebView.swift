// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let model: WebSceneViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.navigationDelegate = model
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: model.url)
        webView.load(request)
    }
}