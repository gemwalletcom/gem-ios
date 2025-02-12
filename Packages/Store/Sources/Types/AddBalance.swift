// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AddBalance {
    public let assetId: String
    public let isEnabled: Bool
    
    public init(assetId: String, isEnabled: Bool) {
        self.assetId = assetId
        self.isEnabled = isEnabled
    }
}

extension AddBalance {
    func mapToAssetBalanceRecord(walletId: String) -> AssetBalanceNewRecord {
        return AssetBalanceNewRecord(
            assetId: assetId,
            walletId: walletId,
            isEnabled: isEnabled
        )
    }
}
