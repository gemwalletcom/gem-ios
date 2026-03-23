// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension FiatTransaction: Identifiable, Hashable {
    public var id: String {
        "\(providerId.rawValue)_\(assetId.identifier)_\(Int(createdAt.timeIntervalSince1970))"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(providerId)
        hasher.combine(assetId)
        hasher.combine(createdAt)
    }
}

extension FiatTransactionInfo: Identifiable, Hashable {
    public var id: String { transaction.id }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(transaction)
    }
}
