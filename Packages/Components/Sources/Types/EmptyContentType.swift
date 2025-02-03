// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum EmptyContentType {
    public enum SearchType {
        case assets
        case networks
    }

    case nfts
    case priceAlerts
    case asset(symbol: String)
    case activity(receive: VoidAction = nil, buy: VoidAction = nil)
    case stake(symbol: String)
    case walletConnect
    case search(type: SearchType, action: VoidAction = nil)
}
