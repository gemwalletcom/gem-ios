// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

// MARK: - Chart Types

public struct ChartSubscription: Equatable, Sendable {
    public let coin: String
    public let period: ChartPeriod

    public init(coin: String, period: ChartPeriod) {
        self.coin = coin
        self.period = period
    }

    public var interval: String {
        switch period {
        case .hour: "1m"
        case .day: "30m"
        case .week: "4h"
        case .month: "12h"
        case .year: "1w"
        case .all: "1M"
        }
    }
}

// MARK: - Request Types

public enum HyperliquidMethod: String, Encodable {
    case subscribe
    case unsubscribe
}

struct HyperliquidRequest: Encodable {
    let method: HyperliquidMethod
    let subscription: HyperliquidSubscription
}

public enum HyperliquidSubscription: Encodable, Sendable {
    case clearinghouseState(user: String)
    case openOrders(user: String)
    case candle(coin: String, interval: String)
    case allMids

    enum CodingKeys: String, CodingKey {
        case type, user, coin, interval
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .clearinghouseState(let user):
            try container.encode("clearinghouseState", forKey: .type)
            try container.encode(user, forKey: .user)
        case .openOrders(let user):
            try container.encode("openOrders", forKey: .type)
            try container.encode(user, forKey: .user)
        case .candle(let coin, let interval):
            try container.encode("candle", forKey: .type)
            try container.encode(coin, forKey: .coin)
            try container.encode(interval, forKey: .interval)
        case .allMids:
            try container.encode("allMids", forKey: .type)
        }
    }
}
