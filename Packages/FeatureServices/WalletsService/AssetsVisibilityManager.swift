// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

struct AssetVisibilityManager: AssetVisibilityServiceable {
    private let service: BalanceService

    init(service: BalanceService) {
        self.service = service
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try service.hideAsset(walletId: walletId, assetId: assetId)
    }

    public func setPinned(_ isPinned: Bool, walletId: WalletId, assetId: AssetId) throws {
        switch isPinned {
        case true: try service.pinAsset(walletId: walletId, assetId: assetId)
        case false: try service.unpinAsset(walletId: walletId, assetId: assetId)
        }
    }
}
