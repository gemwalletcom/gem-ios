// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum CardanoProvider: TargetType {
    case utxos(address: String)
    case genesisConfiguration
    case latestBlock
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .utxos: "queryLedgerState/utxo"
        case .genesisConfiguration: "queryNetwork/genesisConfiguration"
        case .latestBlock: "queryNetwork/tip"
        case .broadcast: "submitTransaction"
        }
    }
    
    public var method: HTTPMethod {
        .POST
    }
    
    public var path: String {
        ""
    }
    
    public var data: RequestData {
        switch self {
        case .utxos(let address):
            .encodable(
                JSONRPCRequest(method: rpc_method, params: ["addresses": [address]], id: 1)
            )
        case .genesisConfiguration:
            .encodable(
                JSONRPCRequest(method: rpc_method, params: ["era": "byron"], id: 1)
            )
        case .latestBlock:
            .encodable(
                JSONRPCRequest(method: rpc_method, params: [:] as [String: String], id: 1)
            )
        case .broadcast(let data):
            .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: ["transaction": ["cbor": data]],
                    id: 1
                )
            )
        }
    }
    
    public var contentType: String {
        ContentType.json.rawValue
    }
}
