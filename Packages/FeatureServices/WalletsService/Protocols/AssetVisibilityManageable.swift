// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

protocol AssetVisibilityServiceable: Sendable {
    func hideAsset(walletId: WalletId, assetId: AssetId) throws
    func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws
}

extension BalanceService: AssetVisibilityServiceable {
    func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        switch isPinned {
        case true: try pinAsset(walletId: walletId, assetId: assetId)
        case false: try unpinAsset(walletId: walletId, assetId: assetId)
        }
    }
}
