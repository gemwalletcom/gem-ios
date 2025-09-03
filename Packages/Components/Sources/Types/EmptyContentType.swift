// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum EmptyContentType {
    public enum SearchType {
        case assets
        case networks
        case activity
    }

    case nfts(action: (() -> Void)? = nil)
    case priceAlerts
    case asset(symbol: String, buy: (() -> Void)? = nil, walletType: WalletType)
    case activity(receive: (() -> Void)? = nil, buy: (() -> Void)? = nil, walletType: WalletType)
    case stake(symbol: String)
    case walletConnect
    case search(type: SearchType, action: (() -> Void)? = nil)
    case markets
}
