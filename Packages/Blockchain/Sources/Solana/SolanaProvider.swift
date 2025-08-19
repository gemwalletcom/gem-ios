// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum SolanaProvider: TargetType, BatchTargetType {
    
    static let defaultCommitment = "confirmed"
    
    public struct Options: Sendable {
        let skipPreflight: Bool
    }
    
    case getTokenAccountsByOwner(owner: String, token: String)
    case latestBlockhash
    case fees
    case slot
    case broadcast(data: String, options: Options?)
    case getAccountInfo(account: String)
    case genesisHash

    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .getTokenAccountsByOwner: "getTokenAccountsByOwner"
        case .latestBlockhash: "getLatestBlockhash"
        case .fees: "getRecentPrioritizationFees"
        case .slot: "getSlot"
        case .broadcast: "sendTransaction"
        case .getAccountInfo: "getAccountInfo"
        case .genesisHash: "getGenesisHash"
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
        case .latestBlockhash,
            .fees,
            .slot,
            .genesisHash:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [] as [String])
            )
        case .getTokenAccountsByOwner(let owner, let token):
            let params: [JSON] = [
                .value(owner),
                .dictionary(["mint": .value(token)]),
                .dictionary([
                    "commitment": .value(Self.defaultCommitment),
                    "encoding": .value("jsonParsed"),
                ]),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        case .broadcast(let data, let options):
            
            // JSON enum is hard to manipulate
            var params: [JSON] = [
                .string(data),
                .dictionary(["encoding": .value("base64")])
            ]
            
            if let options = options {
                params = [
                    .string(data),
                    .dictionary([
                        "encoding": .value("base64"),
                        "skipPreflight": .bool(options.skipPreflight),
                    ])
                ]
            }
            
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params)
            )
        case .getAccountInfo(let account):
            let params: [JSON] = [
                .string(account),
                .dictionary([
                    "encoding": .value("jsonParsed"),
                    "commitment": .value(Self.defaultCommitment),
                ]),
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
