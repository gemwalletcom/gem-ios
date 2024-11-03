// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct UpdateBalance {
    public let assetID: String
    public let type: UpdateBalanceType
    public let updatedAt: Date
    
    public init(
        assetID: String,
        type: UpdateBalanceType,
        updatedAt: Date
    ) {
        self.assetID = assetID
        self.type = type
        self.updatedAt = updatedAt
    }
}
