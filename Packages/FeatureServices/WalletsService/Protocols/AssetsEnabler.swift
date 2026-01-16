// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol AssetsEnabler: Sendable {
    func enableAssets(walletId: WalletId, assetIds: [AssetId], enabled: Bool) async
}
