// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetUpdate: Sendable {
    public let walletId: WalletId
    public let assetIds: [AssetId]
    
    public init(walletId: WalletId, assetIds: [AssetId]) {
        self.walletId = walletId
        self.assetIds = assetIds
    }
}
