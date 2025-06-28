// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetUpdate: Sendable {
    public let walletId: WalletId
    public let assetIds: [AssetId]
}
