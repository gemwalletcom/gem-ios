// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension FiatTransaction: Identifiable, Hashable {
    public var id: String {
        "\(providerId.rawValue)_\(providerTransactionId)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(providerId)
        hasher.combine(providerTransactionId)
    }
}
