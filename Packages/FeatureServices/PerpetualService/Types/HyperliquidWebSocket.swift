// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

// MARK: - Request Types

enum HyperliquidMethod: String, Encodable {
    case subscribe
    case unsubscribe
}

struct HyperliquidRequest: Encodable {
    let method: HyperliquidMethod
    let subscription: HyperliquidSubscription
}

enum HyperliquidSubscription: Encodable {
    case clearinghouseState(user: String)
    case openOrders(user: String)

    enum CodingKeys: String, CodingKey {
        case type, user
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .clearinghouseState(let user):
            try container.encode("clearinghouseState", forKey: .type)
            try container.encode(user, forKey: .user)
        case .openOrders(let user):
            try container.encode("openOrders", forKey: .type)
            try container.encode(user, forKey: .user)
        }
    }
}
