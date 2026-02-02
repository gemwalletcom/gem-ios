// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TronVote: Sendable, Equatable {
    public let validator: String
    public let count: UInt64

    public init(validator: String, count: UInt64) {
        self.validator = validator
        self.count = count
    }
}

public struct TronUnfreeze: Sendable, Equatable {
    public let resource: Resource
    public let amount: UInt64

    public init(resource: Resource, amount: UInt64) {
        self.resource = resource
        self.amount = amount
    }
}

public enum TronStakeData: Sendable, Equatable {
    case votes([TronVote])
    case unfreeze([TronUnfreeze])
}
