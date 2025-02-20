// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum URLAction: Equatable {
    case walletConnect(uri: String)
    case walletConnectRequest
    case asset(AssetId)
}
