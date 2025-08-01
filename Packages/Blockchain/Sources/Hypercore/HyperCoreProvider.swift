// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient

public enum HypercoreProvider: TargetType {
    case clearinghouseState(user: String)
    case metaAndAssetCtxs
    case candleSnapshot(coin: String, interval: String, startTime: Int, endTime: Int)
    case userRole(address: String)
    case referral(address: String)
    case builderFee(address: String, builder: String)
    case broadcast(data: String)

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
            .candleSnapshot,
            .userRole,
            .referral,
            .builderFee:
            return "/info"
        case .broadcast:
            return "/exchange"
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
        case .broadcast(let data):
            return .data(try! data.encodedData())
        }
    }

    public var contentType: String {
        ContentType.json.rawValue
    }
}
