// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct UpdateBalance {
    public let assetId: AssetId
    public let type: UpdateBalanceType
    public let updatedAt: Date
    public let isActive: Bool

    public init(
        assetId: AssetId,
        type: UpdateBalanceType,
        updatedAt: Date,
        isActive: Bool
    ) {
        self.assetId = assetId
        self.type = type
        self.updatedAt = updatedAt
        self.isActive = isActive
    }
}
