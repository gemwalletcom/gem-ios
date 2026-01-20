// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WebKit
import SwiftUI

@Observable
@MainActor
public final class WebSceneViewModel: NSObject, Sendable {
    let url: URL
    var isLoading: Bool = true

    public init(url: URL) {
        self.url = url
    }
}

// MARK: - WKNavigationDelegate

extension WebSceneViewModel: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        isLoading = true
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        isLoading = false
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        isLoading = false
    }
}
