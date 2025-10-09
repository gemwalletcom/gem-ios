// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol AssetVisibilityServiceable: Sendable {
    func hideAsset(walletId: WalletId, assetId: AssetId) throws
    func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws
}
