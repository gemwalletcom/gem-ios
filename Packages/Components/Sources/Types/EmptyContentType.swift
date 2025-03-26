// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum EmptyContentType {
    public enum SearchType {
        case assets
        case networks
        case activity
    }

    case nfts(action: (() -> Void)? = nil)
    case priceAlerts
    case asset(symbol: String)
    case activity(receive: (() -> Void)? = nil, buy: (() -> Void)? = nil)
    case stake(symbol: String)
    case walletConnect
    case search(type: SearchType, action: (() -> Void)? = nil)
    case markets
}
