// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum NearProvider: TargetType {
    case gasPrice
    case account(address: String)
    case accountAccessKey(address: String, publicKey: String)
    case latestBlock
    case transaction(id: String, senderAddress: String)
    case genesisConfig
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .gasPrice: "gas_price"
        case .account, .accountAccessKey: "query"
        case .latestBlock: "block"
        case .transaction: "tx"
        case .genesisConfig: "EXPERIMENTAL_genesis_config"
        case .broadcast: "send_tx"
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
        case .gasPrice:
            let params: [JSON<String>] = [.null]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        case .account(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    "request_type": "view_account",
                    "finality": "final",
                    "account_id": address
                ])
            )
        case .accountAccessKey(let address, let publicKey):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    "request_type": "view_access_key",
                    "finality": "final",
                    "account_id": address,
                    "public_key": publicKey,
                ])
            )
        case .latestBlock:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    "finality": "final",
                ])
            )
        case .transaction(let id, let senderAddress):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    "tx_hash": id,
                    "sender_account_id": senderAddress,
                    "wait_until": "EXECUTED"
                ])
            )
        case .genesisConfig:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [:] as [String:String])
            )
        case .broadcast(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [
                    "signed_tx_base64": data,
                ])
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
