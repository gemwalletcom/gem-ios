// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum GemAPIStatic: TargetType {
    case getValidators(chain: String)
    
    public var baseUrl: URL {
        return URL(string: "https://assets.gemwallet.com")!
    }
    
    public var method: HTTPMethod {
        .GET
    }
    
    public var path: String {
        switch self {
        case .getValidators(let chain):
            return "/blockchains/\(chain)/validators.json"
        }
    }
    
    public var task: Task {
        switch self {
        case .getValidators:
            return .plain
        }
    }
}
