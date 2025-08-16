// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient

public enum HypercoreProvider: TargetType {
    case userRole(address: String)
    case referral(address: String)
    case builderFee(address: String, builder: String)
    case userFees(user: String)
    case extraAgents(user: String)

    public var baseUrl: URL {
        return URL(string: "")!
    }

    public var method: HTTPMethod {
        return .POST
    }

    public var path: String {
        switch self {
        case .userRole,
            .referral,
            .builderFee,
            .userFees,
            .extraAgents:
            return "/info"
        }
    }

    public var data: RequestData {
        switch self {
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
        case .extraAgents(let user):
            return .encodable([
                "type": "extraAgents",
                "user": user
            ])
        }
    }

    public var contentType: String {
        ContentType.json.rawValue
    }
}
