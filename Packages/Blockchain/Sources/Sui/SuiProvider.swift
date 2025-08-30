// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum SuiProvider: TargetType {
    case coins(address: String, coinType: String)
    case dryRun(data: String)
    case getObject(id: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .coins: "suix_getCoins"
        case .dryRun: "sui_dryRunTransactionBlock"
        case .getObject: "sui_getObject"
        }
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return ""
    }
    
    public var data: RequestData {
        switch self {
        case .coins(let address, let coinType):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address, coinType])
            )
        case .dryRun(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [data])
            )
        case .getObject(let id):
            let params: [JSON] = [
                .value(id),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
