// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum HypercoreProvider: TargetType {
    case clearinghouseState(user: String)
    case metaAndAssetCtxs
    case candleSnapshot(coin: String, interval: String, startTime: Int, endTime: Int)
    case exchange(action: String, signature: String, nonce: UInt64)

    public var baseUrl: URL {
        return URL(string: "")!
    }

    public var method: HTTPMethod {
        return .POST
    }

    public var path: String {
        switch self {
        case .clearinghouseState, .metaAndAssetCtxs, .candleSnapshot:
            return "/info"
        case .exchange:
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
        case .exchange(let action, let signature, let nonce):
            let action = try! JSONSerialization.jsonObject(with: action.data(using: .utf8)!, options: [])
            let object: [String: Any] = [
                "action": action,
                "signature": signature,
                "nonce": nonce
            ]
            let data = try! JSONSerialization.data(withJSONObject: object, options: [])
            return .data(data)
        }
    }

    public var contentType: String {
        ContentType.json.rawValue
    }
}
