// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum BitcoinProvider: TargetType {
    case utxo(address: String)
    case fee(priority: Int)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .utxo(let address):
            return "/api/v2/utxo/\(address)"
        case .fee(let priority):
            return "/api/v2/estimatefee/\(priority)"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .utxo,
            .fee:
            return .GET
        }
    }
    
    public var data: RequestData {
        switch self {
        case .utxo,
            .fee:
            return .plain
        }
    }
    
    public var contentType: String {
        switch self {
        default:
            return ContentType.json.rawValue
        }
    }
}
