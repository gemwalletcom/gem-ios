// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WebKit
import SwiftUI
import Primitives
import UIKit
import Preferences

@Observable
@MainActor
public final class ChatwootWebViewModel: NSObject, Sendable {
    
    let websiteToken: String
    let baseUrl: URL
    let settings: ChatwootSettings
    let deviceId: String?
    let preferences: Preferences
    
    var isPresentingSupport: Binding<Bool>
    var isLoading: Bool = true
    
    public init(
        websiteToken: String,
        baseUrl: URL,
        deviceId: String?,
        preferences: Preferences = .standard,
        settings: ChatwootSettings = .defaultSettings,
        isPresentingSupport: Binding<Bool>
    ) {
        self.websiteToken = websiteToken
        self.baseUrl = baseUrl
        self.deviceId = deviceId
        self.preferences = preferences
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
            \(setCustomAttributesScript)
            \(chatCloseEventHandler)
            \(chatOpenEventHandler)
          "></script>
        </body>
        </html>
        """
    }
    
    func configureWebView() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: ChatwootHandler.chatClosed.rawValue)
        configuration.userContentController.add(self, name: ChatwootHandler.chatOpened.rawValue)
        return configuration
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
    
    private var setCustomAttributesScript: String {
        """
        window.addEventListener('chatwoot:ready', function () {
          window.$chatwoot.setCustomAttributes({
            deviceId: '\(customAttributesJson.deviceId)',
            iosVersion: '\(customAttributesJson.iosVersion)',
            appVersion: '\(customAttributesJson.appVersion)',
            device: '\(customAttributesJson.device)',
            currency: '\(customAttributesJson.currency)',
            language: '\(customAttributesJson.language)',
            launchesCount: \(customAttributesJson.launchesCount),
            isPushNotificationsEnabled: \(customAttributesJson.isPushEnabled),
            isPriceAlertsEnabled: \(customAttributesJson.isPriceAlertsEnabled)
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
    
    private var chatCloseEventHandler: String {
        eventHandler(event: .closed, handler: .chatClosed, message: .closed)
    }
    
    private var chatOpenEventHandler: String {
        eventHandler(event: .ready, handler: .chatOpened, message: .ready)
    }
    
    private var customAttributesJson: ChatwootCustomAttributes {
        ChatwootCustomAttributes(
            deviceId: deviceId ?? "",
            iosVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.releaseVersionNumber,
            device: UIDevice.current.name,
            currency: preferences.currency,
            language: Locale.current.usageLanguageIdentifier(),
            launchesCount: preferences.launchesCount,
            isPushEnabled: preferences.isPushNotificationsEnabled,
            isPriceAlertsEnabled: preferences.isPriceAlertsEnabled
        )
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
        case .chatClosed: isPresentingSupport.wrappedValue = false
        case .chatOpened: isLoading = false
        default: break
        }
    }
}
