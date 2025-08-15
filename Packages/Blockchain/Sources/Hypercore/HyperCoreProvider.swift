// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient

public enum HypercoreProvider: TargetType {
    case clearinghouseState(user: String)
    case metaAndAssetCtxs
    case spotMetaAndAssetCtxs
    case candleSnapshot(coin: String, interval: String, startTime: Int, endTime: Int)
    case userRole(address: String)
    case referral(address: String)
    case builderFee(address: String, builder: String)
    case userFees(user: String)
    case userFillsByTime(user: String, startTime: Int)
    case extraAgents(user: String)
    case openOrders(user: String)

    public var baseUrl: URL {
        return URL(string: "")!
    }

    public var method: HTTPMethod {
        return .POST
    }

    public var path: String {
        switch self {
        case .clearinghouseState,
            .metaAndAssetCtxs,
            .spotMetaAndAssetCtxs,
            .candleSnapshot,
            .userRole,
            .referral,
            .builderFee,
            .userFees,
            .userFillsByTime,
            .extraAgents,
            .openOrders:
            return "/info"
        }
    }

    public var data: RequestData {
        switch self {
        case .clearinghouseState(let user):
            return .encodable([
                "type": "clearinghouseState",
                "user": user
            ])
        case .metaAndAssetCtxs:
            return .encodable([
                "type": "metaAndAssetCtxs"
            ])
        case .spotMetaAndAssetCtxs:
            return .encodable([
                "type": "spotMetaAndAssetCtxs"
            ])
        case .candleSnapshot(let coin, let interval, let startTime, let endTime):
            return .encodable(JSON<String>.dictionary([
                "type": .value("candleSnapshot"),
                "req": .dictionary([
                    "coin": .value(coin),
                    "interval": .value(interval),
                    "startTime": .integer(startTime),
                    "endTime": .integer(endTime)
                ])
            ]))
        case .userRole(let address):
            return .encodable([
                "type": "userRole",
                "user": address
            ])
        case .referral(let address):
            return .encodable([
                "type": "referral",
                "user": address
            ])
        case .builderFee(let address, let builder):
            return .encodable([
                "type": "maxBuilderFee",
                "user": address,
                "builder": builder
            ])
        case .userFees(let user):
            return .encodable([
                "type": "userFees",
                "user": user
            ])
        case .userFillsByTime(let user, let startTime):
            return .encodable(JSON<String>.dictionary([
                "type": .value("userFillsByTime"),
                "user": .value(user),
                "startTime": .integer(startTime)
            ]))
        case .extraAgents(let user):
            return .encodable([
                "type": "extraAgents",
                "user": user
            ])
        case .openOrders(let user):
            return .encodable([
                "type": "frontendOpenOrders",
                "user": user
            ])
        }
    }

    public var contentType: String {
        ContentType.json.rawValue
    }
}
