// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum XRPProvider: TargetType {
    case account(address: String)
    case accountLines(address: String)
    case accountObjects(address: String)
    case fee
    case transaction(id: String)
    case latestBlock
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .account: "account_info"
        case .accountLines: "account_lines"
        case .fee: "fee"
        case .transaction: "tx"
        case .accountObjects: "account_objects"
        case .latestBlock: "ledger_current"
        case .broadcast: "submit"
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
        case .account(let address), .accountLines(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [[
                    "account":address,
                    "ledger_index": "current",
                ]])
            )
        case .accountObjects(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [[
                    "account":address,
                    "type": "state",
                    "ledger_index": "validated",
                ]])
            )
        case .fee,
            .latestBlock:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [JSON<String>.dictionary([:])])
            )
        case .transaction(let id):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    JSON.dictionary([
                        "transaction": .value(id),
                    ])
                ])
            )
        case .broadcast(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    JSON.dictionary([
                        "tx_blob": .value(data),
                        "fail_hard": .bool(true)
                    ])
                ])
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
