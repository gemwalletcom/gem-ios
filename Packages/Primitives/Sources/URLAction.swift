// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum URLAction: Equatable {
    case walletConnect(uri: String)
    case walletConnectRequest
    case walletConnectSession(String)
    case asset(AssetId)
    case swap(AssetId, AssetId?)
    case perpetuals
    case rewards(code: String)
    case buy(AssetId, amount: Int?)
    case sell(AssetId, amount: Int?)
    case setPriceAlert(AssetId, price: Double)
    case none
}
