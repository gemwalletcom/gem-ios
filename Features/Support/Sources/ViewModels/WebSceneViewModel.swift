// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WebKit
import SwiftUI

@Observable
@MainActor
final class WebSceneViewModel: NSObject, Sendable {
    let url: URL
    var isLoading: Bool = true

    init(url: URL) {
        self.url = url
    }
}

// MARK: - WKNavigationDelegate

extension WebSceneViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        isLoading = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        isLoading = false
    }
}
