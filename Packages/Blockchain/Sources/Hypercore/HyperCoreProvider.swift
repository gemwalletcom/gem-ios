// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum HypercoreProvider: TargetType {
    
    case clearinghouseState(user: String)
    case metaAndAssetCtxs
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return "/info"
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
        }
    }
    
    public var contentType: String {
        ContentType.json.rawValue
    }
}
