// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct UpdateBalance {
    public let assetID: String
    public let type: UpdateBalanceType
    public let updatedAt: Date
    public let isActive: Bool
    public let metadata: BalanceMetadata?
    
    public init(
        assetID: String,
        type: UpdateBalanceType,
        updatedAt: Date,
        isActive: Bool,
        metadata: BalanceMetadata? = nil
    ) {
        self.assetID = assetID
        self.type = type
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.metadata = metadata
    }
}
