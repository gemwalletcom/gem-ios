// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct Constants {
    
    public struct App {
        public static let name = "Gem Wallet"
        public static let website = "https://gemwallet.com"
    }
    
    public struct WalletConnect {
        public static let groupIdentifier = "group.com.gemwallet.ios"
        public static let projectId = "3bc07cd7179d11ea65335fb9377702b6"
    }
    
    public static let apiURL = URL(string: "https://api.gemwallet.com")!
    public static let assetsURL = URL(string: "https://assets.gemwallet.com")!
    
    public static let nodesURL = URL(string: "https://gemnodes.com")!
    public static let nodesEuropeURL = URL(string: "https://eu.gemnodes.com")!
    public static let nodesAsiaURL = URL(string: "https://asia.gemnodes.com")!

    public struct Support {
        public static let chatwootURL = URL(string: "https://support.gemwallet.com")!
        public static let chatwootPublicToken = "21yu9Az48rJHe1rg4poHqLSr"
        public static let domainPolicy = WebViewDomainPolicy(
            allowedDomains: ["gemwallet.com"],
            openExternalLinksInSafari: true
        )
    }

    public static let nodesWebSocketURL = URL(string: "wss://gemnodes.com")!
    public static let nodesWebSocketEuropeURL = URL(string: "wss://eu.gemnodes.com")!
    public static let nodesWebSocketAsiaURL = URL(string: "wss://asia.gemnodes.com")!

    public static let pricesWebSocketURL = URL(string: "wss://api.gemwallet.com/v1/ws/prices")!
}
