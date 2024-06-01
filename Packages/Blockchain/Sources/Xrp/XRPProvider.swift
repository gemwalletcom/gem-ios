// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum XRPProvider: TargetType {
    case account(address: String)
    case fee
    case transaction(id: String)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .account:
            return "account_info"
        case .fee:
            return "fee"
        case .transaction:
            return "tx"
        case .broadcast:
            return "submit"
        }
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return ""
    }
    
    public var task: Task {
        switch self {
        case .account(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [[
                    "account":address,
                    "ledger_index": "current",
                ]], id: 1)
            )
        case .fee:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [JSON<String>.dictionary([:])], id: 1)
            )
        case .transaction(let id):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    JSON.dictionary([
                        "transaction": .value(id),
                    ])
                ], id: 1)
            )
        case .broadcast(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    JSON.dictionary([
                        "tx_blob": .value(data),
                        "fail_hard": .bool(true)
                    ])
                ], id: 1)
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
