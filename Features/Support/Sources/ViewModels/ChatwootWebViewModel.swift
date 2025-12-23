// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WebKit
import SwiftUI
import Primitives
import Preferences
import UIKit
import DeviceService

@Observable
@MainActor
public final class ChatwootWebViewModel: NSObject, Sendable {
    
    let websiteToken: String
    let baseUrl: URL
    let settings: ChatwootSettings
    let supportDeviceId: String
    
    var isPresentingSupport: Binding<Bool>
    var isLoading: Bool = true
    
    public init(
        websiteToken: String,
        baseUrl: URL,
        supportDeviceId: String,
        settings: ChatwootSettings = .defaultSettings,
        isPresentingSupport: Binding<Bool>
    ) {
        self.websiteToken = websiteToken
        self.baseUrl = baseUrl
        self.supportDeviceId = supportDeviceId
        self.settings = settings
        self.isPresentingSupport = isPresentingSupport
    }
    
    var htmlContent: String {
        """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script>
            \(chatwootSettingsScript)
          </script>
        </head>
        <body>
          <script src="\(sdkSourceURL)" async onload="
            \(sdkInitializationScript)
            \(toggleChatScript)
            \(setDeviceIdScript)
            \(chatOpenEventHandler)
          "></script>
        </body>
        </html>
        """
    }

    func configureWebView() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: ChatwootHandler.chatOpened.rawValue)
        configuration.userContentController.addUserScript(hideCloseButtonUserScript)
        return configuration
    }

    private var hideCloseButtonUserScript: WKUserScript {
        let css = """
        .rn-close-button,
        button.rn-close-button,
        .close-button,
        button.close-button {
            display: none !important;
            visibility: hidden !important;
        }
        """

        let source = """
        (function() {
            var style = document.createElement('style');
            style.innerHTML = \(css.debugDescription);
            document.head.appendChild(style);
        })();
        """

        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
    
    // MARK: - Private properties
    
    private var chatwootSettingsScript: String {
        """
        window.chatwootSettings = {
          hideMessageBubble: \(settings.hideMessageBubble),
          locale: '\(settings.locale.identifier)',
          darkMode: '\(settings.darkMode.rawValue)',
          enableEmojiPicker: \(settings.enableEmojiPicker),
          enableEndConversation: \(settings.enableEndConversation)
        };
        """
    }
    
    private var sdkInitializationScript: String {
        """
        window.chatwootSDK.run({
          websiteToken: '\(websiteToken)',
          baseUrl: '\(baseUrl.absoluteString)'
        });
        """
    }
    
    private var setDeviceIdScript: String {
        let os = UIDevice.current.osName
        let device = UIDevice.current.modelName
        let currency = Preferences.standard.currency
        let appVersion = Bundle.main.releaseVersionNumber
        return """
        window.addEventListener('chatwoot:ready', function () {
          window.$chatwoot.setCustomAttributes({
            supportDeviceId: '\(supportDeviceId)',
            platform: 'ios',
            os: '\(os)',
            device: '\(device)',
            currency: '\(currency)',
            app_version: '\(appVersion)'
          });
        });
        """
    }
    
    private var toggleChatScript: String {
        "window.$chatwoot.toggle(open);"
    }
    
    private var sdkSourceURL: String {
        "\(baseUrl.absoluteString)/packs/js/sdk.js"
    }

    private var chatOpenEventHandler: String {
        eventHandler(event: .ready, handler: .chatOpened, message: .ready)
    }
    
    // MARK: - Private methods
    
    private func eventHandler(event: ChatwootJSEvent, handler: ChatwootHandler, message: ChatwootMessage) -> String {
        """
        window.addEventListener('\(event.rawValue)', function(event) {
          if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.\(handler.rawValue)) {
            window.webkit.messageHandlers.\(handler.rawValue).postMessage('\(message.rawValue)');
          }
        });
        """
    }
    
}

// MARK: - WKNavigationDelegate, WKScriptMessageHandler

extension ChatwootWebViewModel: WKNavigationDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch ChatwootHandler(rawValue: message.name) {
        case .chatOpened: isLoading = false
        default: break
        }
    }
}
