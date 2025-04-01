// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

struct AssetVisibilityManager: AssetVisibilityManageable {
    private let service: BalanceService

    init(service: BalanceService) {
        self.service = service
    }

    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try service.hideAsset(walletId: walletId, assetId: assetId)
    }

    public func togglePin(_ shouldPin: Bool, walletId: WalletId, assetId: AssetId) throws {
        switch shouldPin {
        case true: try service.pinAsset(walletId: walletId, assetId: assetId)
        case false: try service.unpinAsset(walletId: walletId, assetId: assetId)
        }
    }
}
