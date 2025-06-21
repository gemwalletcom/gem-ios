// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AddBalance {
    public let assetId: AssetId
    public let isEnabled: Bool
    
    public init(assetId: AssetId, isEnabled: Bool) {
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
