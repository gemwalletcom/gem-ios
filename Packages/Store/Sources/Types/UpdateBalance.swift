// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct UpdateBalance {
    public let assetID: String
    public let available: String
    public let frozen: String
    public let locked: String
    public let staked: String
    public let pending: String
    public let reserved: String
    public let total: Double
    public let fiatValue: Double
    public let updatedAt: Date
    
    public init(
        assetID: String,
        available: String,
        frozen: String,
        locked: String,
        staked: String,
        pending: String,
        reserved: String,
        total: Double,
        fiatValue: Double,
        updatedAt: Date
    ) {
        self.assetID = assetID
        self.available = available
        self.frozen = frozen
        self.locked = locked
        self.staked = staked
        self.pending = pending
        self.reserved = reserved
        self.total = total
        self.fiatValue = fiatValue
        self.updatedAt = updatedAt
    }
}
