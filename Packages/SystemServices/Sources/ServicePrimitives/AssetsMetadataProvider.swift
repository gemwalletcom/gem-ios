// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol AssetsMetadataProvider: Sendable {
    func addBalanceIfMissing(walletId: WalletId, assetId: AssetId) throws
    func updateEnabled(walletId: WalletId, assetIds: [AssetId], enabled: Bool) throws
}