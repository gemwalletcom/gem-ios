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

    public static let chatwootURL = URL(string: "https://support.gemwallet.com")!
    public static let chatwootPublicToken = "21yu9Az48rJHe1rg4poHqLSr"
}
