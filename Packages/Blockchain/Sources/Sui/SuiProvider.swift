// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum SuiProvider: TargetType {
    case coins(address: String, coinType: String)
    case dryRun(data: String)
    case broadcast(data: String, signature: String)
    case getObject(id: String)
    case transaction(id: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .coins: "suix_getCoins"
        case .dryRun: "sui_dryRunTransactionBlock"
        case .broadcast: "sui_executeTransactionBlock"
        case .getObject: "sui_getObject"
        case .transaction: "sui_getTransactionBlock"
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
        case .broadcast(let data, let signature):
            let params: [JSON] = [
                .value(data),
                .array([.string(signature)]),
                .null,
                .value("WaitForLocalExecution")
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        case .getObject(let id):
            let params: [JSON] = [
                .value(id),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        case .transaction(let id):
            let options: [String: JSON<String>] = [
                "showInput": .bool(true),
                "showEffects": .bool(true),
                "showEvents": .bool(true),
                "showObjectChanges": .bool(true),
                "showBalanceChanges": .bool(true)
            ]
            let params: [JSON<String>] = [
                .value(id),
                .dictionary(options)
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
