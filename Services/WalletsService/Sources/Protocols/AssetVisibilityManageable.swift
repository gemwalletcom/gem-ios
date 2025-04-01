// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

protocol AssetVisibilityManageable: Sendable {
    func hideAsset(walletId: WalletId, assetId: AssetId) throws
    func togglePin(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws
}
